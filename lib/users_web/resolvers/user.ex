defmodule UsersWeb.Resolvers.User do
  alias Users.Guardian
  alias Users.Account
  alias Users.Account.User

  defmacro admin_role_context do
    quote do
      %{context: %{current_user: %{role: "admin"}}}
    end
  end

  defmacro super_role_context do
    quote do
      %{context: %{current_user: %{role: "super"}}}
    end
  end

  defmacro admin_only(context, do: block) do
    quote do
      case unquote(context) do
        super_role_context() -> unquote(block)
        admin_role_context() -> unquote(block)
        _                                             -> not_authorized()
      end
    end
  end
  defmacro admin_only(context, user_id, do: block) do
    quote do
      case unquote(context) do
        super_role_context() -> unquote(block)
        admin_role_context() ->
          case Account.get_user(unquote(user_id)) do
            nil  -> not_found()
            user ->
              if user.role === "user" do
                unquote(block)
              else
                not_authorized()
              end
          end
          _                                           -> not_authorized()
      end
    end
  end

  # Allow super admin to create other admin Users
  def create_user(%{admin: true} = args, super_role_context()) do
    case Account.create_admin(args) do
      {:ok, user} -> new_user_with_token(user)
      result      -> result
    end
  end
  # Allow admins to create Users
  def create_user(args, %{context: %{current_user: _}} = context) do
    admin_only(context) do
      create_user(args, nil)
    end
  end
  # Create a User account
  def create_user(args, _context) do
    case Account.create_user(args) do
      {:ok, user} -> new_user_with_token(user)
      result      -> result
    end
  end

  # Get a private User by id if current_user is admin
  def get_private_user(%{id: id}, context) do
    admin_only(context, id) do
      case Account.get_user(id) do
        nil  -> not_found()
        user -> {:ok, user}
      end
    end
  end
  # Get private User of current_user
  def get_private_user(_, %{context: %{current_user: current_user}}), do: {:ok, current_user}
  # Handle unauthorized retrieval of private User
  def get_private_user(_, _), do: not_authorized()

  # Sign in a User
  def sign_in(%{email: email, password: password}, _) do
    case Account.get_user_by_email(email) do
      nil  -> incorrect_email_or_password()
      user ->
        case Pbkdf2.check_pass(user, password, [hash_key: :password]) do
          {:error, "invalid password"}  -> incorrect_email_or_password()
          _                             -> user_with_token(user)
        end
    end
  end

  # Update a User with id if current user is an admin
  def update_user(%{id: id} = args, context) do
    admin_only(context, id) do
      case get_private_user(%{id: id}, context) do
        {:ok, user} ->
          Account.update_user(user, Map.delete(args, :id))
        result      -> result
      end
    end
  end
  # Update the User of the current_user
  def update_user(args, %{context: %{current_user: current_user}}), do: Account.update_user(current_user, args)
  # Handle unauthorized User update
  def update_user(_, _), do: not_authorized()

  # Delete a User with id if current user is an admin
  def delete_user(%{id: id}, context) do
    admin_only(context, id) do
      Account.delete_user(%User{id: id})
    end
  end
  def delete_user(_, %{context: %{current_user: current_user}}), do: Account.delete_user(current_user)
  # Handle unauthorized User deletion
  def delete_user(_, _), do: not_authorized()

  # Confirm User sign up by id if current user if admin
  def confirm_user(%{id: id}, context) do
    admin_only(context, id) do
      case Account.get_user(id) do
        nil  -> not_found()
        user -> Account.confirm_user(user)
      end
    end
  end
  # Confirm User sign up by confirmation token
  def confirm_user(%{confirmation_token: confirmation_token}, _) do
    if confirmation_token === "" do
      not_authorized()
    else
      case Account.get_user_by_confirmation_token(confirmation_token) do
        nil  -> not_authorized()
        user ->
          Account.confirm_user(user)
      end
    end
  end
  # Handle unauthorized User confirmation
  def confirm_user(_, _), do: not_authorized()

  # Get all private Users if current User if super
  def get_all_private_users(_, super_role_context()), do: {:ok, Account.list_users()}
  # Get all Users with "user" role if current User is admin
  def get_all_private_users(_, admin_role_context()), do: {:ok, Account.list_non_admin_users()}
  # Handle unauthorized access of private Users
  def get_all_private_users(_, _), do: not_authorized()

  # Send password reset link to email
  def forgot_password(%{email: email}, _) do
    sent = {:ok, %{sent: true}}

    case Users.Account.get_user_by_email(email) do
      nil  -> sent
      user ->
        password_reset_token = Util.random_string(64)
        # Send password reset token to email here
        IO.puts "======================> password_reset_token: #{password_reset_token}"
        Account.update_user(user, %{password_reset_token: password_reset_token})
        sent
    end
  end

  # Change User password using password_reset_token that was sent to email
  def change_password(%{password_reset_token: password_reset_token, password: password}, _) do
    successful = {:ok, %{success: true}}

    case Account.get_user_by_password_reset_token(password_reset_token) do
      nil  -> successful
      user ->
        # Check if password_reset_token is older than 5 minutes here
        Account.update_password(user, password)
        successful
    end
  end
  # Change password of currently logged in User
  def change_password(%{old_password: old_password, password: password}, %{context: %{current_user: %{email: email} = current_user}}) do
    case sign_in(%{email: email, password: old_password}, nil) do
      {:ok, _} ->
        case Account.update_password(current_user, password) do
          {:ok, _} -> {:ok, %{success: true}}
          result   -> result
        end
      _        -> {:error, "Incorrect password"}
    end
  end
  # Handle unauthorized change of password
  def change_password(_, _), do: not_authorized()

  def not_authorized, do: {:error, "Not Authorized"}
  def not_found, do: {:error, "Not found"}
  defp incorrect_email_or_password, do: {:error, "Incorrect email address or password"}

  defp user_with_token(user) do
    {:ok, token, _} = Guardian.encode_and_sign(user)
    {:ok, %{user: user, token: token}}
  end
  defp new_user_with_token(user) do
    IO.puts "======> confirmation token: #{user.confirmation_token}"
    user_with_token(user)
  end
end
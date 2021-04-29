defmodule UsersWeb.Resolvers.User do
  alias Users.Guardian
  alias Users.Account
  alias Users.Account.User

  defmacro admin_only(context, do: block) do
    quote do
      case unquote(context) do
        %{context: %{current_user: %{role: "super"}}} -> unquote(block)
        %{context: %{current_user: %{role: "admin"}}} -> unquote(block)
        _                                             -> not_authorized()
      end
    end
  end

  # Allow super admin to create other admin Users
  def create_user(%{admin: true} = args, %{context: %{current_user: %{role: "super"}}}) do
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
    admin_only(context) do
      case Account.get_user(id) do
        nil  -> not_found()
        user -> {:ok, user}
      end
    end
  end
  # Get private User of current_user
  def get_private_user(_, %{context: %{current_user: current_user}}), do: current_user
  # Handle unauthorized retrieval of private User
  def get_private_user(_, _), do: not_authorized()

  # Sign in a User
  def sign_in(%{email: email, password: password}, _) do
    case Account.get_user_by_email(email) do
      nil  -> incorrect_email_or_password()
      user ->
        case Pbkdf2.check_pass(user, password) do
          nil  -> incorrect_email_or_password()
          _    -> user_with_token(user)
        end
    end
  end

  # Update a User with id if current user is an admin
  def update_user(%{id: id} = args, context) do
    admin_only(context) do
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
    admin_only(context) do
      Account.delete_user(%User{id: id})
    end
  end
  def delete_user(_, %{context: %{current_user: current_user}}), do: Account.delete_user(current_user)

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
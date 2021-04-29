defmodule UsersWeb.Resolvers.User do
  defmacro admin_only(%{context: %{current_user: %{role: "super"}}}, do: block), do: quote do: unquote(block)
  defmacro admin_only(%{context: %{current_user: %{role: "admin"}}}, do: block), do: quote do: unquote(block)
  defmacro admin_only(_, _), do: quote do: not_authorized()

  # Allow super admin to create other admin Users
  def create_user(%{admin: true} = args, %{context: %{current_user: %{role: "super"}}}) do
    case Users.Account.create_admin(args) do
      {:ok, user} ->
        IO.puts "======> confirmation token: #{user.confirmation_token}"
        {:ok, token, _} = Users.Guardian.encode_and_sign(user)
        {:ok, %{user: user, token: token}}
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
    case Users.Account.create_user(args) do
      {:ok, user} ->
        IO.puts "======> confirmation token: #{user.confirmation_token}"
        {:ok, token, _} = Users.Guardian.encode_and_sign(user)
        {:ok, %{user: user, token: token}}
      result      -> result
    end
  end

  # Get a private User by id if current_user is admin
  def get_private_user(%{id: id}, context) do
    admin_only(context) do
      case Users.Account.get_user(id) do
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
    case Users.Account.get_user_by_email(email) do
      nil  -> incorrect_email_or_password()
      user ->
        case Pbkdf2.check_pass(user, password) do
          nil  -> incorrect_email_or_password()
          _    ->
            {:ok, token, _} = Users.Guardian.encode_and_sign(user)
            {:ok, %{user: user, token: token}}
        end
    end
  end

  # Update a User with id if current user is an admin
  def update_user(%{id: id} = args, context) do
    admin_only(context) do
      case get_private_user(%{id: id}, context) do
        {:ok, user} ->
          Users.Account.update_user(user, Map.delete(args, :id))
        result      -> result
      end
    end
  end
  # Update the User of the current_user
  def update_user(args, %{context: %{current_user: current_user}}), do: Users.Account.update_user(current_user, args)
  # Handle unauthorized User update
  def update_user(_, _), do: not_authorized()

  def not_authorized, do: {:error, "Not Authorized"}
  def not_found, do: {:error, "Not found"}
  defp incorrect_email_or_password, do: {:error, "Incorrect email address or password"}
end
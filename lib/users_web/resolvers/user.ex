defmodule UsersWeb.Resolvers.User do
  # Allow super admin to create other admin Users
  def create_user(%{admin: true} = args, %{context: %{current_user: %{role: "super"}}}), do: Users.Account.create_admin(args)
  # Handle not authorized if current_user want to create an admin but is not super
  def create_user(%{admin: true}, _), do: not_authorized
  # Allow admins to create Users
  def create_user(args, %{context: %{context: %{current_user: %{role: role}}}}) do
    case role do
      "admin" -> create_user(args, nil)
      "super" -> create_user(args, nil)
      _       -> not_authorized
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
  def get_private_user(%{id: id}, %{context: %{current_user: %{role: "admin"}}}), do: {:ok, Users.Account.get_user(id)}
  # Get private User for current_user
  def get_private_user(_, %{context: %{current_user: current_user}}), do: current_user

  defp not_authorized, do: {:error, "Not Authorized"}
end
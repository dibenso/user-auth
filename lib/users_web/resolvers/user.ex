defmodule UsersWeb.Resolvers.User do
  def create_user(args, _context) do
    case Users.Account.create_user(args) do
      {:ok, user} ->
        IO.puts "======> confirmation token: #{user.confirmation_token}"
        {:ok, token, _} = Users.Guardian.encode_and_sign(user)
        {:ok, %{user: Map.put(user, :token, token), token: token}}
      result      -> result
    end
  end

  def get_user(_args, %{context: %{current_user: current_user}}) do
    {:ok, current_user}
  end

  def get_user(_, _) do
    {:error, "Not Authorized"}
  end
end
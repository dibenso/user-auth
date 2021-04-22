defmodule UsersWeb.UserResolver do
  def create_user(_parent, args, _context) do
    case Users.Account.create_user(args) do
      {:ok, user} ->
        IO.puts "======> confirmation token: #{user.confirmation_token}"
        {:ok, token, _} = Users.Guardian.encode_and_sign(user)
        {:ok, %{user: Map.put(user, :token, token), token: token}}
      result      -> result
    end
  end
end
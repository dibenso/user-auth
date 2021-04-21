defmodule UsersWeb.Schema do
  use Absinthe.Schema
  import AbsintheErrorPayload.Payload
  import_types AbsintheErrorPayload.ValidationMessageTypes

  object :user, description: "A User" do
    field :id, non_null(:id), description: "unique identifier"
    field :username, non_null(:string), description: "User's username"
    field :email, non_null(:string), description: "User's email address"
    field :inserted_at, non_null(:string), description: "Created at"
    field :updated_at, non_null(:string), description: "Last updated at"
    field :token, :string, description: "Authentication token"
  end

  payload_object(:user_payload, :user)

  query do
    @desc "Root query"
    field :app, :string do
      resolve fn (_, _, _) -> {:ok, "Hello"} end
    end
  end

  mutation do
    @desc "Create a user"
    field :create_user, type: :user_payload, description: "create a user" do
      arg :username, non_null(:string)
      arg :email, non_null(:string)
      arg :password, non_null(:string)
  
      resolve(fn (_, args, _) -> create_user(args) end)

      middleware &build_payload/2
    end
  end

  defp create_user(args) do
    case Users.Account.create_user(args) do
      {:ok, user} ->
        {:ok, token, _} = Users.Guardian.encode_and_sign(user)
        {:ok, Map.put(user, :token, token)}
      result      -> result
    end
  end
end
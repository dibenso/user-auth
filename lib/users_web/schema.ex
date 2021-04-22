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
  end

  object :authenticated_user, description: "A User with authentication token" do
    field :user, non_null(:user), description: "Authenticated user"
    field :token, :string, description: "Authentication token"
  end

  payload_object(:user_payload, :authenticated_user)

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
  
      resolve(&UsersWeb.UserResolver.create_user/3)

      middleware &build_payload/2
    end
  end
end
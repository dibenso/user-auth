defmodule UsersWeb.Schema do
  use Absinthe.Schema
  import AbsintheErrorPayload.Payload
  import_types AbsintheErrorPayload.ValidationMessageTypes

  object :user, description: "A User" do
    field :id, non_null(:id), description: "Unique identifier"
    field :username, non_null(:string), description: "User's username"
    field :email, non_null(:string), description: "User's email address"
    field :inserted_at, non_null(:string), description: "Time User was created"
    field :updated_at, non_null(:string), description: "Last time User was updated"
    field :confirmed, non_null(:boolean), description: "Indicates if User confirmed registration"
  end

  object :authenticated_user, description: "A User with authentication token" do
    field :user, non_null(:user), description: "Authenticated User"
    field :token, :string, description: "Authentication token"
  end

  payload_object(:user_payload, :user)
  payload_object(:user_with_token_payload, :authenticated_user)

  query do
    @desc "Root query"
    field :app, :string do
      resolve fn (_, _, _) -> {:ok, "Hello"} end
    end

    @desc "Get a User"
    field :get_user, type: :user_payload, description: "Get a User" do
      resolve(&UsersWeb.Resolvers.User.get_user/2)

      middleware &build_payload/2
    end
  end

  mutation do
    @desc "Create a User"
    field :create_user, type: :user_with_token_payload, description: "Create a User" do
      arg :username, non_null(:string)
      arg :email, non_null(:string)
      arg :password, non_null(:string)
  
      resolve(&UsersWeb.Resolvers.User.create_user/2)

      middleware &build_payload/2
    end
  end
end
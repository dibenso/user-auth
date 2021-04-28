defmodule UsersWeb.Schema do
  use Absinthe.Schema
  import AbsintheErrorPayload.Payload
  import_types AbsintheErrorPayload.ValidationMessageTypes

  object :private_user, description: "A User" do
    field :id, non_null(:id), description: "Unique identifier"
    field :username, non_null(:string), description: "User's username"
    field :email, non_null(:string), description: "User's email address"
    field :inserted_at, non_null(:string), description: "Time User was created"
    field :updated_at, non_null(:string), description: "Last time User was updated"
    field :confirmed, non_null(:boolean), description: "Indicates if User confirmed registration"
  end

  object :authenticated_user, description: "A User with authentication token" do
    field :user, non_null(:private_user), description: "Authenticated User"
    field :token, :string, description: "Authentication token"
  end

  payload_object(:private_user_payload, :private_user)
  payload_object(:authenticated_user_payload, :authenticated_user)

  query do
    @desc "Root query"
    field :app, :string do
      resolve fn (_, _, _) -> {:ok, "Hello"} end
    end

    @desc "Get current User or User by id if admin"
    field :get_private_user, type: :private_user_payload do
      arg :id, :id, description: "User id to allow admin access to private user information"

      resolve(&UsersWeb.Resolvers.User.get_private_user/2)

      middleware &build_payload/2
    end

    @desc "Sign in a User"
    field :sign_in, type: :authenticated_user_payload do
      arg :email, non_null(:string), description: "Email address of User"
      arg :password, non_null(:string), description: "Password of User"

      resolve(&UsersWeb.Resolvers.User.sign_in/2)

      middleware &build_payload/2
    end
  end

  mutation do
    @desc "Create a User"
    field :create_user, type: :authenticated_user_payload do
      arg :username, non_null(:string), description: "Username"
      arg :email, non_null(:string), description: "Email"
      arg :password, non_null(:string), description: "Password"
      arg :admin, :boolean, description: "If User will be an admin"
  
      resolve(&UsersWeb.Resolvers.User.create_user/2)

      middleware &build_payload/2
    end
  end
end
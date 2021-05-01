defmodule UsersWeb.Schema do
  use Absinthe.Schema
  import AbsintheErrorPayload.Payload
  import_types AbsintheErrorPayload.ValidationMessageTypes

  object :private_user, description: "A User" do
    field :id, non_null(:integer), description: "Unique identifier"
    field :username, non_null(:string), description: "User's username"
    field :email, non_null(:string), description: "User's email address"
    field :inserted_at, non_null(:string), description: "Time User was created"
    field :updated_at, non_null(:string), description: "Last time User was updated"
    field :confirmed, non_null(:boolean), description: "Indicates if User confirmed registration"
    field :role, non_null(:string), description: "Role of User"
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
      arg :id, :integer, description: "User id to allow admin access to private user information"

      resolve(&UsersWeb.Resolvers.User.get_private_user/2)

      middleware &build_payload/2
    end

    @desc "Get all private Users if admin"
    field :get_all_private_users, type: :private_user_payload do
      resolve(&UsersWeb.Resolvers.User.get_all_private_users/2)

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

    @desc "Update the User of current User or by id if admin"
    field :update_user, type: :private_user_payload do
      arg :id, :integer, description: "Update user by id if admin"
      arg :username, :string, description: "Updated username"
      arg :confirmed, :boolean, description: "Updated confirmation status"

      resolve(&UsersWeb.Resolvers.User.update_user/2)

      middleware &build_payload/2
    end

    @desc "Delete the current User or User by id if admin"
    field :delete_user, type: :private_user_payload do
      arg :id, :integer, description: "Delete User by id if admin"

      resolve(&UsersWeb.Resolvers.User.delete_user/2)

      middleware &build_payload/2
    end

    @desc "Confirms User with token or by id if admin"
    field :confirm_user, type: :private_user_payload do
      arg :id, :integer, description: "Confirm User by id if admin"
      arg :confirmation_token, :string, description: "Sign up confirmation token"

      resolve(&UsersWeb.Resolvers.User.confirm_user/2)

      middleware &build_payload/2
    end
  end
end
defmodule Users.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :confirmation_token, :string
    field :confirmed, :boolean, default: false
    field :email, :string
    field :password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> change(%{password: Pbkdf2.hash_pwd_salt(attrs[:password])})
    |> validate_length(:username, min: 4, max: 32)
  end
end

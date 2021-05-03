defmodule Users.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :confirmation_token, :string
    field :confirmed, :boolean, default: false
    field :email, :string
    field :password, :string
    field :username, :string
    field :role, :string, default: "user"
    field :password_reset_token, :string
    field :password_reset_time, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_required([:username, :email, :password])
    |> validate_length(:username, min: 2, max: 32)
    |> validate_format(:username, ~r/^[a-zA-Z0-9_.-]*$/)
    |> validate_length(:email, max: 256)
    |> validate_format(:email, ~r/^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)
    |> validate_length(:password, min: 8, max: 256)
    |> validate_format(:password, ~r/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/)
    |> validate_format(:role, ~r/^(user|admin|super)$/)
    |> change(%{password: Pbkdf2.hash_pwd_salt(attrs[:password]), confirmation_token: Util.random_string(64), confirmed: false})
    |> unique_constraint(:email)
    |> unique_constraint(:confirmation_token)
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :confirmed, :confirmation_token, :password_reset_token])
    |> validate_length(:username, min: 2, max: 32)
    |> validate_format(:username, ~r/^[a-zA-Z0-9_.-]*$/)
    |> unique_constraint(:password_reset_token)
  end

  def update_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 256)
    |> validate_format(:password, ~r/^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/)
    |> change(%{password: Pbkdf2.hash_pwd_salt(attrs[:password]), confirmation_token: Util.random_string(64), confirmed: false})
  end
end

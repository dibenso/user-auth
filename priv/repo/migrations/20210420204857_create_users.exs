defmodule Users.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :password_hash, :string
      add :confirmed, :boolean, default: false, null: false
      add :confirmation_token, :string

      timestamps()
    end

  end
end

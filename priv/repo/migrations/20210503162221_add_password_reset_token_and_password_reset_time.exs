defmodule Users.Repo.Migrations.AddPasswordResetTokenAndPasswordResetTime do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :password_reset_token, :string
      add :password_reset_time, :utc_datetime
    end

    create unique_index(:users, [:password_reset_token])
  end
end

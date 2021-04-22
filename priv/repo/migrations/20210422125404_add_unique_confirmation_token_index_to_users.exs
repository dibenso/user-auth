defmodule Users.Repo.Migrations.AddUniqueConfirmationTokenIndexToUsers do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:confirmation_token])
  end
end

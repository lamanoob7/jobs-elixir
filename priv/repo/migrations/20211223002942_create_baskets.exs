defmodule Binshop.Repo.Migrations.CreateBaskets do
  use Ecto.Migration

  def change do
    create table(:baskets) do
      add :amount, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:baskets, [:user_id])
  end
end

defmodule Binshop.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :description, :text
      add :is_visible, :boolean, default: false, null: false
      add :is_deleted, :boolean, default: false, null: false

      timestamps()
    end

    create index(:categories, [:is_visible])
    create index(:categories, [:is_deleted])
  end
end

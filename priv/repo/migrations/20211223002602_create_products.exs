defmodule Binshop.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :description, :text
      add :price, :float
      add :price_without_vat, :float
      add :vat, :float
      add :image, :string
      add :is_visible, :boolean, default: false, null: false
      add :is_deleted, :boolean, default: false, null: false

      timestamps()
    end

    create index(:products, [:is_visible])
    create index(:products, [:is_deleted])
  end
end

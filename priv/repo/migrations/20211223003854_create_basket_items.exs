defmodule Binshop.Repo.Migrations.CreateBasketItems do
  use Ecto.Migration

  def change do
    create table(:basket_items) do
      add :basket_id, references(:baskets, on_delete: :nothing), primary_key: true
      add :amount, :integer
      add :price, :float
      add :price_without_vat, :float
      add :vat, :float
      add :product_id, references(:products, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:basket_items, [:basket_id])
    create index(:basket_items, [:product_id])
    create index(:basket_items, [:user_id])
  end
end

defmodule Binshop.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table(:order_items) do
      add :amount, :integer
      add :price, :float
      add :price_without_vat, :float
      add :vat, :float
      add :order_id, references(:orders, on_delete: :nothing), primary_key: true
      add :product_id, references(:products, on_delete: :nothing), primary_key: true

      timestamps()
    end

    create unique_index(:order_items, [:order_id, :product_id])
  end
end

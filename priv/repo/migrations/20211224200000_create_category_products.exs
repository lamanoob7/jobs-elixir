defmodule Binshop.Repo.Migrations.CreateCategoryProducts do
  use Ecto.Migration

  def change do
    create table(:product_categories) do
      add :category_id, references(:categories, on_delete: :nothing)
      add :product_id, references(:products, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:product_categories, [:category_id, :product_id])
  end
end

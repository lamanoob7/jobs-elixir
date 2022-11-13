defmodule Binshop.Repo.Migrations.AddProductSlug do
  use Ecto.Migration

  alias Binshop.Products.Product
  alias Binshop.Repo

  def up do
    alter table(:products) do
      add :slug, :string, null: true
    end

    create unique_index(:products, [:slug])

    flush()

    ecto_query =
      Product
      |> Product.filter_by_slug(nil)

    Repo.all(ecto_query)
    |> Enum.each(fn x ->
      create_slug(x)
      flush()
    end)

    alter table("products") do
      modify :slug, :string, null: false
    end
  end

  def down do
    alter table(:products) do
      remove :slug
    end
  end

  defp create_slug(product) do
    product
    |> Product.changeset(%{slug: Slug.slugify(product.name)})
    |> Repo.update()
  end
end

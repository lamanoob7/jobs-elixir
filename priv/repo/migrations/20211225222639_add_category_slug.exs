defmodule Binshop.Repo.Migrations.AddCategorySlug do
  use Ecto.Migration

  alias Binshop.Categories.Category
  alias Binshop.Repo

  def up do
    alter table(:categories) do
      add :slug, :string, null: true
    end

    create unique_index(:categories, [:slug])

    flush()

    ecto_query =
      Category
      |> Category.filter_by_slug(nil)

    Repo.all(ecto_query)
    |> Enum.each(fn x ->
      create_slug(x)
      flush()
    end)

    alter table("categories") do
      modify :slug, :string, null: false
    end
  end

  def down do
    alter table(:categories) do
      remove :slug
    end
  end

  defp create_slug(category) do
    category
    |> Category.changeset(%{slug: Slug.slugify(category.name)})
    |> Repo.update()
  end
end

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirTemplate.Repo.insert!(%ElixirTemplate.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

defmodule Binshop.DatabaseSeeder do
  alias Binshop.Categories.Category
  alias Binshop.Products.Product
  alias Binshop.Products.ProductCategory
  alias Binshop.Repo

  @categories [
    %{
      name: "Category 1",
      description: "Product category 1 description text",
      image: "uploads/categories/11df85d2-d4d9-4878-a739-e17ed8a4f638.jpg",
      is_visible: false,
      is_deleted: false
    },
    %{
      name: "Category 2",
      description: "Product category 2 description text",
      image: "uploads/categories/582efcdd-0564-4993-aacb-bf3d87168eb9.jpg",
      is_visible: false,
      is_deleted: false
    },
    %{
      name: "Category 3",
      description: "Product category 3 description text",
      image: "uploads/categories/5b19380f-ad18-4bb2-a4eb-71e059df31ea.jpg",
      is_visible: false,
      is_deleted: false
    },
    %{
      name: "Category 4",
      description: "Product category 4 description text",
      image: "uploads/categories/c4217d21-4918-4270-97bf-342bbb885694.jpg",
      is_visible: false,
      is_deleted: false
    },
    %{
      name: "Category 5",
      description: "Product category 5 description text",
      image: "uploads/categories/582efcdd-0564-4993-aacb-bf3d87168eb9.jpg",
      is_visible: false,
      is_deleted: false
    },
    %{
      name: "Category 6",
      description: "Product category 6 description text",
      image: "uploads/categories/99048dd7-4d9b-4471-b66f-3fbaa8ee4a7e.jpg",
      is_visible: false,
      is_deleted: false
    },
    %{
      name: "Category 7",
      description: "Product category 7 description text",
      image: "uploads/categories/5b19380f-ad18-4bb2-a4eb-71e059df31ea.jpg",
      is_visible: false,
      is_deleted: false
    },
    %{
      name: "Category deleted",
      description: "Product category deleted description text",
      image: "uploads/categories/11df85d2-d4d9-4878-a739-e17ed8a4f638.jpg",
      is_visible: false,
      is_deleted: true
    },
    %{
      name: "Category 8 not visible",
      description: "Product category 8 description text",
      image: "uploads/categories/6f6fd156-f2c5-4e8c-82a7-25e47c7f5cdb.jpg",
      is_visible: false,
      is_deleted: false
    },
    %{
      name: "Category 9 not visible",
      description: "Product category 9 description text",
      image: "uploads/categories/98d5f2c4-0f39-464c-8440-ddea2b26c208.jpg",
      is_visible: false,
      is_deleted: false
    }
  ]

  @products Enum.map(1..25, fn i ->
              price_base = 5 * :rand.uniform(100)

              %{
                description: "product number #{i} and his description",
                is_deleted: false,
                is_visible: true,
                name: "product #{i} name",
                price: price_base * 1.21,
                price_without_vat: price_base,
                vat: price_base * 0.21
              }
            end)

  @product_categories [
    {1, 5},
    {2, 15},
    {3, 0},
    {4, 2},
    {5, 25},
    {6, 10},
    {7, 11},
    {8, 2},
    {9, 1}
  ]

  def insert_categories do
    Enum.map(@categories, fn c ->
      Repo.insert!(Category.changeset(%Category{}, c))
    end)
  end

  def insert_products do
    Enum.map(@products, fn p ->
      Repo.insert!(Product.changeset(%Product{}, p))
    end)
  end

  def insert_products do
    Enum.map(@products, fn p ->
      Repo.insert!(Product.changeset(%Product{}, p))
    end)
  end

  def insert_product_categories(products, categories) do
    product_count = length(products)

    Enum.each(@product_categories, fn {key, number} ->
      category_id =
        categories
        |> Enum.at(key - 1)
        |> Map.get(:id)

      product_categories =
        products
        |> Enum.slice(0..(number - 1))
        |> Enum.map(fn p ->
          pc = %{
            category_id: category_id,
            product_id: p.id
          }

          Repo.insert!(ProductCategory.changeset(%ProductCategory{}, pc))
        end)
    end)
  end

  def clean() do
    Repo.delete_all(ProductCategory)
    Repo.delete_all(Product)
    Repo.delete_all(Category)
  end
end

Binshop.DatabaseSeeder.clean()
categories = Binshop.DatabaseSeeder.insert_categories()
products = Binshop.DatabaseSeeder.insert_products()
product_categories = Binshop.DatabaseSeeder.insert_product_categories(products, categories)

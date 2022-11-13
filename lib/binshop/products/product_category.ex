defmodule Binshop.Products.ProductCategory do
  @moduledoc """
  Product Category Ecto scheme for keep many-to-many relationship between products and categories

  It is possible to add relation ship directly using ProductCategory or using many-to-many relation in Categories or Products
  """
  use Binshop.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  schema "product_categories" do
    belongs_to :category, Binshop.Categories.Category
    belongs_to :product, Binshop.Products.Product

    timestamps()
  end

  @doc false
  def changeset(product_category, attrs) do
    product_category
    |> cast(attrs, [:category_id, :product_id])
    |> validate_required([:category_id, :product_id])
    |> assoc_constraint(:category)
    |> assoc_constraint(:product)
    |> unique_constraint([:category_id, :product_id],
      name: :product_categories_category_id_product_id_index,
      message: "Combination of category and product is already used"
    )
    |> unique_constraint([:category, :product],
      name: :product_categories_category_id_product_id_index,
      message: "Combination of category and product is already used"
    )
  end

  def filter_by_category_id(queryable, id) do
    from product_category in queryable, where: product_category.category_id == ^id
  end

  def filter_by_product_id(queryable, id) do
    from product_category in queryable, where: product_category.product_id == ^id
  end

  def preload_category(queryable, true) do
    from product_category in queryable,
      inner_join: category in assoc(product_category, :category),
      preload: [
        category: category
      ]
  end

  def preload_category(queryable, _), do: queryable

  def preload_product(queryable, true) do
    from product_category in queryable,
      inner_join: product in assoc(product_category, :product),
      preload: [
        product: product
      ]
  end

  def preload_product(queryable, _), do: queryable
end

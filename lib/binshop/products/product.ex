defmodule Binshop.Products.Product do
  @moduledoc """
  Product ecto schema
  """
  use Binshop.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Binshop.Categories.Category
  alias Binshop.Products.ProductCategory

  schema "products" do
    field :description, :string
    field :is_deleted, :boolean, default: false
    field :is_visible, :boolean, default: false
    field :name, :string
    field :price, :float
    field :price_without_vat, :float
    field :vat, :float
    field :image, :string
    field :slug, :string, nullable: false

    timestamps()

    many_to_many :categories, Category, join_through: ProductCategory, unique: true
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :description,
      :price,
      :price_without_vat,
      :vat,
      :is_visible,
      :image,
      :slug
    ])
    |> validate_required([
      :name,
      :description,
      :price,
      :price_without_vat,
      :vat,
      :is_visible
    ])
    |> slugify(:name)
    |> unique_constraint(:slug)
  end

  def delete_changeset(product, attrs) do
    product
    |> cast(attrs, [:is_deleted])
    |> validate_required([:is_deleted])
  end

  def filter_not_deleted(queryable) do
    from product in queryable, where: product.is_deleted == false
  end

  def filter_by_id(queryable, id) do
    from product in queryable, where: product.id == ^id
  end

  def filter_by_is_visible(queryable, is_visible) when is_boolean(is_visible) do
    from product in queryable, where: product.is_visible == ^is_visible
  end

  def filter_visible(queryable, _) do
    queryable
  end

  def filter_by_slug(queryable, nil) do
    from category in queryable, where: is_nil(category.slug)
  end

  def filter_by_slug(queryable, slug) when is_binary(slug) do
    from category in queryable, where: category.slug == ^slug
  end

  def filter_by_slug(queryable, _), do: queryable

  def add_product(queryable, %Binshop.Products.Product{} = product_struct) do
    from product in queryable, or_where: product.id == ^product_struct.id
  end

  def add_product(queryable, nil), do: queryable

  def filter_by_name(queryable, name) when is_binary(name) do
    from product in queryable, where: ilike(product.name, ^"%#{name}%")
  end

  def filter_by_name(queryable, _), do: queryable

  def order_by_field(queryable, "name") do
    from product in queryable, order_by: [asc: product.name]
  end

  def order_by_field(queryable, "-name") do
    from product in queryable, order_by: [desc: product.name]
  end

  def order_by_field(queryable, "visible") do
    from product in queryable, order_by: [asc: product.is_visible, asc: product.name]
  end

  def order_by_field(queryable, "-visible") do
    from product in queryable, order_by: [desc: product.is_visible, asc: product.name]
  end

  def order_by_field(queryable, "date") do
    from product in queryable, order_by: [asc: product.inserted_at]
  end

  def order_by_field(queryable, "-date") do
    from product in queryable, order_by: [desc: product.inserted_at]
  end

  def order_by_field(queryable, "price") do
    from product in queryable, order_by: [asc: product.price]
  end

  def order_by_field(queryable, "-price") do
    from product in queryable, order_by: [desc: product.price]
  end

  def order_by_field(queryable, "price_without_vat") do
    from product in queryable, order_by: [asc: product.price_without_vat]
  end

  def order_by_field(queryable, "-price_without_vat") do
    from product in queryable, order_by: [desc: product.price_without_vat]
  end

  def order_by_field(queryable, "vat") do
    from product in queryable, order_by: [asc: product.vat]
  end

  def order_by_field(queryable, "-vat") do
    from product in queryable, order_by: [desc: product.vat]
  end

  def preload_categories(queryable, true) do
    from product in queryable,
      left_join: categories in assoc(product, :categories),
      preload: [
        categories: categories
      ]
  end

  def preload_categories(queryable, _), do: queryable
end

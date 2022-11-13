defmodule Binshop.Categories.Category do
  @moduledoc """
  Category ecto schema
  """
  use Binshop.Schema

  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  alias Binshop.Products.Product
  alias Binshop.Products.ProductCategory

  schema "categories" do
    field :description, :string
    field :is_deleted, :boolean, default: false
    field :is_visible, :boolean, default: false
    field :name, :string
    field :image, :string
    field :slug, :string, nullable: false

    timestamps()

    many_to_many :products, Product, join_through: ProductCategory, unique: true
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :description, :is_visible, :image, :slug])
    |> validate_required([:name, :description, :is_visible])
    |> slugify(:name)
    |> unique_constraint(:slug)
  end

  def delete_changeset(category, attrs) do
    category
    |> cast(attrs, [:is_deleted])
    |> validate_required([:is_deleted])
  end

  def filter_not_deleted(queryable) do
    from category in queryable, where: category.is_deleted == false
  end

  def filter_by_id(queryable, id) do
    from category in queryable, where: category.id == ^id
  end

  def filter_by_name(queryable, name) when is_binary(name) do
    from category in queryable, where: ilike(category.name, ^"%#{name}%")
  end

  def filter_by_name(queryable, _), do: queryable

  def filter_by_slug(queryable, nil) do
    from category in queryable, where: is_nil(category.slug)
  end

  def filter_by_slug(queryable, slug) when is_binary(slug) do
    from category in queryable, where: category.slug == ^slug
  end

  def filter_by_slug(queryable, _), do: queryable

  def or_category(queryable, %Binshop.Categories.Category{} = category_struct) do
    from category in queryable, or_where: category.id == ^category_struct.id
  end

  def or_category(queryable, nil), do: queryable

  def order_by_field(queryable, "name") do
    from category in queryable, order_by: [asc: category.name]
  end

  def order_by_field(queryable, "-name") do
    from category in queryable, order_by: [desc: category.name]
  end

  def order_by_field(queryable, "visible") do
    from category in queryable, order_by: [asc: category.is_visible, asc: category.name]
  end

  def order_by_field(queryable, "-visible") do
    from category in queryable, order_by: [desc: category.is_visible, asc: category.name]
  end

  def order_by_field(queryable, "date") do
    from category in queryable, order_by: [asc: category.inserted_at]
  end

  def order_by_field(queryable, "-date") do
    from category in queryable, order_by: [desc: category.inserted_at]
  end

  def preload_products(queryable, true) do
    from category in queryable,
      left_join: products in assoc(category, :products),
      preload: [
        products: products
      ]
  end

  def preload_products(queryable, _), do: queryable
end

defimpl Phoenix.Param, for: Binshop.Categories.Category do
  def to_param(%{id: id}) do
    id
  end

  def to_param(%{slug: slug}) do
    slug
  end
end

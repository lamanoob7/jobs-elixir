defmodule Binshop.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias Binshop.Repo

  alias Binshop.Products.Product

  require Logger

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    page_size = Keyword.get(opts, :page_size, 30)

    ecto_query = products_query(opts)

    Repo.paginate(ecto_query, page: page, page_size: page_size)
  end

  def public_list_products(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    page_size = Keyword.get(opts, :page_size, 30)

    ecto_query =
      products_query(opts)
      |> Product.filter_by_is_visible(true)

    Repo.paginate(ecto_query, page: page, page_size: page_size)
  end

  def get_products(opts \\ []) do
    list_products(opts)
    |> Map.get(:entries, [])
  end

  def get_public_products(opts \\ []) do
    public_list_products(opts)
    |> Map.get(:entries, [])
  end

  defp products_query(opts) do
    page = Keyword.get(opts, :page, 1)
    page_size = Keyword.get(opts, :page_size, 30)
    sort = Keyword.get(opts, :sort, "name")
    name = Keyword.get(opts, :name)

    Logger.debug([
      "Accessed list of products",
      "\n  Opts: #{inspect(%{page: page, page_size: page_size, sort: sort, name: name})}}"
    ])

    Product
    |> Product.filter_not_deleted()
    |> Product.filter_by_name(name)
    |> Product.order_by_field(sort)
  end

  def public_list_products_by_ids(ids, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    page_size = Keyword.get(opts, :page_size, 30)

    ecto_query =
      products_query(opts)
      |> Product.filter_by_is_visible(true)
      |> where([p], p.id in ^ids)

    Repo.paginate(ecto_query, page: page, page_size: page_size)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id, opts \\ []) do
    preload_categories = Keyword.get(opts, :preload_categories)

    q =
      Product
      |> Product.filter_not_deleted()
      |> Product.preload_categories(preload_categories)

    Repo.get!(q, id)
  end

  @doc """
  Gets a single product by slug.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product_by_slug!("slug-text")
      %Product{}

      iex> get_product_by_slug!("bad-slug-text")
      ** (Ecto.NoResultsError)

  """
  def get_product_by_slug!(slug, opts \\ []) do
    preload_categories = Keyword.get(opts, :preload_categories)

    Product
    |> Product.filter_not_deleted()
    |> Product.filter_by_slug(slug)
    |> Product.preload_categories(preload_categories)
    |> Repo.one!()
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    product
    |> Product.delete_changeset(%{is_deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end

  alias Binshop.Products.ProductCategory

  @doc """
  Returns the list of product_categories.

  ## Examples

      iex> list_product_categories()
      [%ProductCategory{}, ...]

  """
  def list_product_categories(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    page_size = Keyword.get(opts, :page_size, 30)

    Logger.debug([
      "Accessed list of products",
      "\n  Opts: #{inspect(%{page: page, page_size: page_size})}}"
    ])

    ecto_query =
      ProductCategory
      |> ProductCategory.preload_category(true)
      |> ProductCategory.preload_product(true)

    Repo.paginate(ecto_query, page: page, page_size: page_size)
  end

  @doc """
  Gets a single product_category.

  Raises `Ecto.NoResultsError` if the Product category does not exist.

  ## Examples

      iex> get_product_category!(123)
      %ProductCategory{}

      iex> get_product_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product_category!(id) do
    ProductCategory
    |> ProductCategory.preload_category(true)
    |> ProductCategory.preload_product(true)
    |> Repo.get!(id)
  end

  @doc """
  Gets a single product_category by its category and product.

  Raises `Ecto.NoResultsError` if the Product category does not exist.

  ## Examples

      iex> get_product_category!(123, 456)
      %ProductCategory{}

      iex> get_product_category!(456, 456)
      ** (Ecto.NoResultsError)

  """
  def get_product_category!(category_id, product_id) do
    ProductCategory
    |> ProductCategory.filter_by_category_id(category_id)
    |> ProductCategory.filter_by_product_id(product_id)
    |> ProductCategory.preload_category(true)
    |> ProductCategory.preload_product(true)
    |> Repo.one!()
  end

  @doc """
  Creates a product_category.

  ## Examples

      iex> create_product_category(%{field: value})
      {:ok, %ProductCategory{}}

      iex> create_product_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product_category(attrs \\ %{}) do
    %ProductCategory{}
    |> ProductCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product_category.

  ## Examples

      iex> update_product_category(product_category, %{field: new_value})
      {:ok, %ProductCategory{}}

      iex> update_product_category(product_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product_category(%ProductCategory{} = product_category, attrs) do
    product_category
    |> ProductCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product_category.

  ## Examples

      iex> delete_product_category(product_category)
      {:ok, %ProductCategory{}}

      iex> delete_product_category(product_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product_category(%ProductCategory{} = product_category) do
    Repo.delete(product_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product_category changes.

  ## Examples

      iex> change_product_category(product_category)
      %Ecto.Changeset{data: %ProductCategory{}}

  """
  def change_product_category(%ProductCategory{} = product_category, attrs \\ %{}) do
    ProductCategory.changeset(product_category, attrs)
  end

  @doc """
  List of non deleted products for select option with possible to include selected deleted product
  """
  def products_for_select(category \\ nil) do
    Logger.debug([
      "Accessed list of categories for select",
      "\n  Opts: #{inspect(%{category: category})}}"
    ])

    ecto_query =
      Product
      |> Product.filter_not_deleted()
      |> Product.order_by_field("name")

    Repo.all(ecto_query)
  end
end

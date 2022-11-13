defmodule Binshop.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  alias Binshop.Repo

  alias Binshop.Categories.Category

  require Logger

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    page_size = Keyword.get(opts, :page_size, 30)
    sort = Keyword.get(opts, :sort, "name")
    name = Keyword.get(opts, :name)

    Logger.debug([
      "Accessed list of categories",
      "\n  Opts: #{inspect(%{page: page, page_size: page_size, sort: sort, name: name})}}"
    ])

    ecto_query =
      Category
      |> Category.filter_not_deleted()
      |> Category.filter_by_name(name)
      |> Category.order_by_field(sort)

    Repo.paginate(ecto_query, page: page, page_size: page_size)
  end

  def get_categories(opts \\ []) do
    list_categories(opts)
    |> Map.get(:entries, [])
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id, opts \\ []) do
    preload_products = Keyword.get(opts, :preload_products)

    Category
    |> Category.filter_not_deleted()
    |> Category.preload_products(preload_products)
    |> Repo.get!(id)
  end

  @doc """
  Gets a single category by slug.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!("slug-text")
      %Category{}

      iex> get_category!("bad-slug-text")
      ** (Ecto.NoResultsError)

  """
  def get_category_by_slug!(slug, opts \\ []) do
    preload_products = Keyword.get(opts, :preload_products)

    Category
    |> Category.filter_not_deleted()
    |> Category.filter_by_slug(slug)
    |> Category.preload_products(preload_products)
    |> Repo.one!()
  end

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    category
    |> Category.delete_changeset(%{is_deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  @doc """
  List of non deleted categories for select option with possible to include selected deleted category
  """
  def categories_for_select(category \\ nil) do
    Logger.debug([
      "Accessed list of categories for select",
      "\n  Opts: #{inspect(%{category: category})}}"
    ])

    ecto_query =
      Category
      |> Category.filter_not_deleted()
      |> Category.order_by_field("name")

    Repo.all(ecto_query)
  end
end

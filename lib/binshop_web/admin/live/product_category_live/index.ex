defmodule BinshopWeb.Admin.ProductCategoryLive.Index do
  @moduledoc """
  Product Category live show modul
  """
  use BinshopWeb, :live_view

  alias Binshop.Categories
  alias Binshop.Products
  alias Binshop.Products.ProductCategory
  alias BinshopWeb.Web.LiveHelpers

  alias Surface.Components.{Link, LivePatch, LiveRedirect}

  @default_page_size "20"

  @impl true
  def mount(_params, _session, socket) do
    {product_categories, paginate} = list_product_categories(socket)

    {:ok,
     socket
     |> assign(:name, "")
     |> assign(:loading, false)
     |> assign(:product_categories, product_categories)
     |> assign(:categories, product_categories)
     |> assign(:products, Products.get_products(sort: "-visible"))
     |> assign(:category, Categories.get_categories(sort: "-visible"))
     |> assign(:paginate, paginate)
     |> assign(:page, 1)
     |> assign(:page_size, @default_page_size)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product category")
    |> assign(:product_category, Products.get_product_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product category")
    |> assign(:product_category, %ProductCategory{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Product categories")
    |> assign(:product_category, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product_category = Products.get_product_category!(id)
    {:ok, _} = Products.delete_product_category(product_category)

    {product_categories, paginate} = list_product_categories(socket)

    {:noreply,
     socket |> assign(:product_categories, product_categories) |> assign(:paginate, paginate)}
  end

  defp list_product_categories(socket, opts \\ []) do
    page = LiveHelpers.get_value(socket, opts, :page)
    page_size = LiveHelpers.get_value(socket, opts, :page_size)

    Products.list_product_categories(page: page, page_size: page_size)
    |> Map.pop(:entries)
  end
end

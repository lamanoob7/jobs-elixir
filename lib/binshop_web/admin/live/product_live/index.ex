defmodule BinshopWeb.Admin.ProductLive.Index do
  @moduledoc """
  Products live modul
  """
  use BinshopWeb, :live_view

  alias Binshop.Products
  alias Binshop.Products.Product
  alias BinshopWeb.Web.LiveHelpers

  alias Surface.Components.{Form, Link, LivePatch, LiveRedirect}
  alias Surface.Components.Form.{Submit, TextInput}

  @default_page_size "20"
  @default_sort "name"

  @impl true
  def mount(_params, _session, socket) do
    {products, paginate} = list_products(socket)

    {:ok,
     socket
     |> assign(:name, "")
     |> assign(:sort, @default_sort)
     |> assign(:loading, false)
     |> assign(:products, products)
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
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Products.get_product!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, %Product{})
  end

  defp apply_action(socket, :index, params) do
    page = String.to_integer(params["page"] || "1")
    page_size = String.to_integer(params["page_size"] || @default_page_size)
    sort = params["sort"] || @default_sort

    {products, paginate} = list_products(socket, sort: sort, page: page, page_size: page_size)

    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
    |> assign(:products, products)
    |> assign(:paginate, paginate)
    |> assign(:page, page)
    |> assign(:page_size, page_size)
    |> assign(:sort, sort)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Products.get_product!(id)
    {:ok, _} = Products.delete_product(product)

    {products, paginate} = list_products(socket)
    {:noreply, socket |> assign(:products, products) |> assign(:paginate, paginate)}
  end

  ##############
  # Private
  defp list_products(socket, opts \\ []) do
    name = LiveHelpers.get_value(socket, opts, :name)
    page = LiveHelpers.get_value(socket, opts, :page)
    page_size = LiveHelpers.get_value(socket, opts, :page_size)
    sort = LiveHelpers.get_value(socket, opts, :sort, @default_sort)

    Products.list_products(name: name, sort: sort, page: page, page_size: page_size)
    |> Map.pop(:entries)
  end
end

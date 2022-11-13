defmodule BinshopWeb.Admin.CategoryLive.Index do
  @moduledoc """
  Categories live modul
  """
  use BinshopWeb, :live_view

  alias Binshop.Categories
  alias Binshop.Categories.Category
  alias BinshopWeb.Web.LiveHelpers

  alias Surface.Components.{Form, Link, LivePatch, LiveRedirect}
  alias Surface.Components.Form.{Submit, TextInput}

  prop page_title, :string
  prop category, :struct

  @default_page_size "20"
  @default_sort "name"

  @impl true
  def mount(_params, _session, socket) do
    {categories, paginate} = list_categories(socket)

    {:ok,
     socket
     |> assign(:name, "")
     |> assign(:sort, @default_sort)
     |> assign(:loading, false)
     |> assign(:categories, categories)
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
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Categories.get_category!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :index, params) do
    page = String.to_integer(params["page"] || "1")
    page_size = String.to_integer(params["page_size"] || @default_page_size)
    sort = params["sort"] || @default_sort

    {categories, paginate} = list_categories(socket, sort: sort, page: page, page_size: page_size)

    socket
    |> assign(:page_title, "Listing Categories")
    |> assign(:category, nil)
    |> assign(:categories, categories)
    |> assign(:paginate, paginate)
    |> assign(:page, page)
    |> assign(:page_size, page_size)
    |> assign(:sort, sort)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    category = Categories.get_category!(id)
    {:ok, _} = Categories.delete_category(category)

    {categories, paginate} = list_categories(socket)
    {:noreply, socket |> assign(:categories, categories) |> assign(:paginate, paginate)}
  end

  def handle_event("search-name", %{"name" => name}, socket) do
    send(self(), {:run_search_name, name})

    {:noreply, assign(socket, categories: [], name: name, loading: true)}
  end

  @impl true
  def handle_info({:run_search_name, name}, socket) do
    {categories, paginate} = list_categories(socket, name: name)

    socket =
      case length(categories) do
        0 ->
          socket
          |> put_flash(:info, "No categories found for \"#{name}\"")

        _ ->
          socket
          |> assign(categories: categories)
      end

    {:noreply, assign(socket |> assign(paginate: paginate), name: name, loading: false)}
  end

  ##############
  # Private
  defp list_categories(socket, opts \\ []) do
    name = LiveHelpers.get_value(socket, opts, :name)
    page = LiveHelpers.get_value(socket, opts, :page)
    page_size = LiveHelpers.get_value(socket, opts, :page_size)
    sort = LiveHelpers.get_value(socket, opts, :sort, @default_sort)

    Categories.list_categories(name: name, sort: sort, page: page, page_size: page_size)
    |> Map.pop(:entries)
  end
end

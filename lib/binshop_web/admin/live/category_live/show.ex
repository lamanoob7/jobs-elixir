defmodule BinshopWeb.Admin.CategoryLive.Show do
  @moduledoc """
  Category live show modul
  """
  use BinshopWeb, :live_view

  alias Binshop.Categories
  alias Binshop.Products.ProductCategory
  alias Surface.Components.{LivePatch, LiveRedirect}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    category = Categories.get_category!(id, preload_products: true)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:category, category)
     |> assign(:product_category, %ProductCategory{category_id: category.id})}
  end

  defp page_title(:show), do: "Show Category"
  defp page_title(:edit), do: "Edit Category"
  defp page_title(:add_category), do: "Add Product"
end

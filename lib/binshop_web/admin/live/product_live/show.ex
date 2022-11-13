defmodule BinshopWeb.Admin.ProductLive.Show do
  @moduledoc """
  Category live show modul
  """
  use BinshopWeb, :live_view

  alias Binshop.Products
  alias Binshop.Products.ProductCategory
  alias Surface.Components.LivePatch

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    product = Products.get_product!(id, preload_categories: true)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:product, product)
     |> assign(:product_category, %ProductCategory{product_id: product.id})}
  end

  defp page_title(:show), do: "Show Product"
  defp page_title(:edit), do: "Edit Product"
  defp page_title(:add_category), do: "Add into Category"
end

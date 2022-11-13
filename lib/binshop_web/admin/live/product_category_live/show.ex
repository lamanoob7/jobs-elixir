defmodule BinshopWeb.Admin.ProductCategoryLive.Show do
  @moduledoc """
  Product Category relation live show modul
  """
  use BinshopWeb, :live_view

  alias Binshop.Products
  alias Surface.Components.{LivePatch, LiveRedirect}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:product_category, Products.get_product_category!(id))}
  end

  defp page_title(:show), do: "Show Product category"
  defp page_title(:edit), do: "Edit Product category"
end

defmodule BinshopWeb.Web.ProductLive.Show do
  @moduledoc """
  Product live show modul
  """
  use BinshopWeb, :live_view

  alias Binshop.Products

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    product = Products.get_product_by_slug!(slug, preload_categories: true)

    {:ok,
     socket
     |> assign(:product, product)
     |> assign(:page_title, "Product #{product.name}")}
  end
end

defmodule BinshopWeb.Web.PageLive do
  @moduledoc """
  Default live page module
  """

  use BinshopWeb, :live_view

  alias Binshop.Categories
  alias Binshop.Products

  @impl true
  def mount(_params, _session, socket) do
    categories = Categories.get_categories()
    products = Products.get_public_products()

    {:ok,
     socket
     |> assign(:categories, categories)
     |> assign(products: products)}
  end
end

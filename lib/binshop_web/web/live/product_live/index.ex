defmodule BinshopWeb.Web.ProductLive.Index do
  @moduledoc """
  Default live page module
  """

  use BinshopWeb, :live_view

  alias Binshop.Products

  @impl true
  def mount(_params, _session, socket) do
    {products, paginate} = list_products(socket)

    {:ok,
     socket
     |> assign(:products, products)
     |> assign(:paginate, paginate)
     |> assign(:page_title, "Products")}
  end

  ##############
  # Private
  defp list_products(_socket, _opts \\ []) do
    Products.list_products(sort: "name", page: 1, page_size: 10)
    |> Map.pop(:entries)
  end
end

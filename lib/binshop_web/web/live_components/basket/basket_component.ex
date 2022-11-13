defmodule BinshopWeb.Components.Basket.BasketComponent do
  @moduledoc """
  Basket product
  """
  use BinshopWeb, :live_component

  alias Binshop.Baskets
  alias BinshopWeb.Components.Basket.{BasketInfo, ProductComponent, ProductsList}

  prop basket_storage_id, :string
  data basket, :struct
  data basket_products, :list

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    basket = Baskets.get(assigns.basket_storage_id)

    {
      :ok,
      socket
      |> assign(basket: basket)
      |> assign(basket_products: Baskets.get_products(basket))
    }
  end

  def handle_info(:remove_basket_product, socket) do
    basket = Baskets.get(socket.assigns.basket_storage_id)

    {:ok,
    socket
    |> update(:basket, basket)
    # |> assign(basket_products: Baskets.get_products(basket))
  }
  end


  @impl true
  def render(assigns) do
    ~F"""
    <div>
    <BasketInfo {=@basket} />
    <ProductsList {=@basket} {=@basket_products} />
    </div>
    """
  end
end

defmodule BinshopWeb.Components.Basket.ProductsList do
  @moduledoc """
  Basket product
  """
  use BinshopWeb, :component

  alias BinshopWeb.Components.Basket.ProductComponent

  prop basket, :struct
  prop basket_products, :list

  @impl true
  def render(assigns) do
    ~F"""
    <div>
      <h3>In basket</h3>
      <div>
        {#for product <- @basket_products}
          <ProductComponent id={"basket_product_#{product.id}"} {=product} basket_storage_id={@basket.basket_storage_id}/>
        {#else}
          Oh, no...Your basket is sooooo empty
        {/for}
      </div>
    </div>
    """
  end
end

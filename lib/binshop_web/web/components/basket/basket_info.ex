defmodule BinshopWeb.Components.Basket.BasketInfo do
  @moduledoc """
  Basket product
  """
  use BinshopWeb, :component

  prop basket, :struct

  @impl true
  def render(assigns) do
    ~F"""
    <div>
      <div><h2>Basket:</h2></div>
      <div>Total items: {@basket.items_amount}</div>
    </div>
    """
  end
end

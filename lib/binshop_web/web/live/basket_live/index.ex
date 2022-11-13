defmodule BinshopWeb.Web.BasketLive.Index do
  @moduledoc """
  Default live page module
  """
  use BinshopWeb, :live_view

  alias BinshopWeb.Components.Basket.BasketComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Basket")}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <section class="basket-products">
      <BasketComponent id="basket" {=@basket_storage_id} />
    </section>
    """
  end
end

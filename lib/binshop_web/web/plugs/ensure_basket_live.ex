defmodule BinshopWeb.Plugs.EnsureBasketLive do
  @moduledoc """
  This plug is responsible for passing basket storage id into socket
  """
  import Phoenix.LiveView

  alias BinshopWeb.Plugs.EnsureBasket

  def mount(_params, %{"_binshop_web_basket_storage_id" => basket_storage_id} = _session, socket),
    do: {:cont, assign_new(socket, EnsureBasket.basket_storage_id_assign(), fn -> basket_storage_id end)}

  def mount(_params, _session, socket),
    do: {:cont, assign(socket, EnsureBasket.basket_storage_id_assign(), nil)}
end

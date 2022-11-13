defmodule BinshopWeb.Components.ProductComponent do
  @moduledoc """
  Category live form component
  """
  use BinshopWeb, :live_component

  alias Binshop.Baskets
  alias BinshopWeb.Router.Helpers, as: Routes
  alias Surface.Components.LiveRedirect
  alias Surface.Components.Form.TextInput

  prop product, :struct
  prop basket_storage_id, :string
  prop amount, :integer, default: 0

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    basket_amount =
      Baskets.get_product(assigns.basket_storage_id, assigns.product.id)
      |> case do
        nil -> 0
        number -> number
      end

    {:ok,
     assign(socket,
       basket_storage_id: assigns.basket_storage_id,
       product: assigns.product,
       amount: basket_amount
     )}
  end

  @impl true
  def handle_event("inc", _, socket) do
    {:noreply,
     update(socket, :amount, fn count ->
       new_count = count + 1

       Baskets.update_product(
         socket.assigns.basket_storage_id,
         socket.assigns.product.id,
         new_count
       )

       new_count
     end)}
  end

  @impl true
  def handle_event("dec", _, socket) do
    {:noreply,
     update(socket, :amount, fn count ->
       new_count = if count < 1, do: 0, else: count - 1

       Baskets.update_product(
         socket.assigns.basket_storage_id,
         socket.assigns.product.id,
         new_count
       )

       new_count
     end)}
  end

  @impl true
  def handle_event("reset", _, socket) do
    {:noreply, assign(socket, :amount, 0)}
  end

  @impl true
  def render(assigns) do
    ~F"""
    <div class="product" id="product-<%= @product.id %>">
      <div>
        <img src={"#{Binshop.Media.path_photo(@product.image)}"} style="width: 160px;" />
      </div>
      <div>
        <span>
          <LiveRedirect to={Routes.product_show_path(@socket, :show, @product.slug)}>{@product.name}</LiveRedirect>
        </span>
      </div>
      <div class="amount product-amount">
        <button type="submit" class="amount-dec" :on-click="dec" value="-" disabled={@amount < 1}>-</button>
        <TextInput name="amount" class="control amount-amount" value={@amount}/>
        <button type="submit" class="amount-inc" :on-click="inc" value="+">+</button>
      </div>
      <div>{@product.description}</div>
    </div>
    """
  end
end

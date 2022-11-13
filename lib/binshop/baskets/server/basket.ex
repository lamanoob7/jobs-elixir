defmodule Binshop.Baskets.Server.Basket do
  @moduledoc """
  This module manages the Video encode process.
  Processes can be dynamically started and terminated.
  """

  use GenServer

  alias Binshop.Baskets.Storage.Basket

  ###############
  # CLIENT

  # @impl true
  # def add(basket_id, product_id, amount) do
  #   storage().add(basket_id, product_id, amount)
  # end

  # @impl true
  # def update(basket_id, product_id, amount) do
  #   storage().add(basket_id, product_id, amount)
  # end

  # @impl true
  # def remove(basket_id, product_id, amount) do
  #   storage().add(basket_id, product_id, amount)
  # end

  # @doc """
  # Starts new or return existing Video encode process via Swarm.
  # """
  # defp ensure_basket(basket_id) do
  #   basket_id
  #   |> case do
  #     nil ->

  #   end
  # end

  @doc """
  Explicit server lookup in global registry.
  """
  def whereis(basket_storage_id) do
    case :global.whereis_name({__MODULE__, basket_storage_id}) do
      :undefined -> nil
      pid -> pid
    end
  end

  ###############
  # SERVER
  def start_link(%{id: basket_storage_id, keep_alive: keep_alive}) do
    now = DateTime.utc_now()

    basket_storage = %Basket{
      basket_storage_id: basket_storage_id,
      created_at: now,
      updated_at: now,
      keep_alive: keep_alive
    }

    IO.inspect(basket_storage)
    GenServer.start_link(__MODULE__, basket_storage, name: global_name(basket_storage_id))
  end

  @impl GenServer
  def init(state) do
    {:ok, state, {:continue, :init_load_products}}
  end

  @impl GenServer
  def handle_continue(:init_load_products, state) do
    # Process.send_after(self(), :load_products, @load_products_reload)
    {:noreply, state}
  end

  @impl GenServer
  def handle_call(:get_basket, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call({:get_product, product_id}, _from, %{items: items} = state) do
    {:reply, Map.get(items, product_id), state}
  end

  @impl GenServer
  def handle_cast({:update_product, product_id, amount}, %{items: items} = state) do
    new_items = Map.put(items, product_id, amount)

    {:noreply, state |> Map.put(:items, new_items) |> recalculate_total_items_amount()}
  end

  @impl GenServer
  def handle_cast({:remove_product, product_id}, %{items: items} = state) do
    new_items =
      items
      |> Map.get(product_id)
      |> case do
        nil -> items
        _ -> Map.delete(items, product_id)
      end

    {:noreply, state |> Map.put(:items, new_items)}
  end

  ###############
  # PRIVATE
  defp global_name(bank_account_id) do
    {:global, {__MODULE__, bank_account_id}}
  end

  defp recalculate_total_items_amount(%{items: items} = state) do
    total_amount = Enum.reduce(items, 0, fn {_, amount}, acc -> amount + acc end)
    Map.put(state, :items_amount, total_amount)
  end
end

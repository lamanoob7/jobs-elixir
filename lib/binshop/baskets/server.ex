defmodule Binshop.Baskets.Server do
  @moduledoc """
  This module dynamically manages the baskets in server storage.
  """

  @behaviour Binshop.Baskets.Storage

  use DynamicSupervisor

  alias Binshop.Baskets.Server.Basket, as: ServerBasket

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  ###############
  # CLIENT
  @impl true
  def create() do
    basket_storage_id = UUID.uuid4()

    spec = %{
      :id => "Basket_storage_#{basket_storage_id}",
      :start => {
        ServerBasket,
        :start_link,
        [
          %{
            id: basket_storage_id,
            keep_alive: config()[:basket_keep_alive]
          }
        ]
      },
      :restart => :transient
    }

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, _pid} ->
        {:ok, get(basket_storage_id)}

      {:error, reason} ->
        {:error, reason}

      any ->
        {:error, any}
    end
  end

  @impl true
  def exists?(basket_storage_id) do
    basket_storage_id
    |> ServerBasket.whereis()
    |> is_pid()
  end

  @impl true
  def get(basket_storage_id) do
    GenServer.call(ServerBasket.whereis(basket_storage_id), :get_basket)
  end

  @impl true
  def delete(basket_storage_id) do
    basket = get(basket_storage_id)
    GenServer.stop(ServerBasket.whereis(basket_storage_id))
    {:ok, basket}
  end

  def count_baskets() do
    %{
      specs: all,
      active: active,
      supervisors: _supervisors,
      workers: _workers
    } = DynamicSupervisor.count_children(__MODULE__)

    %{
      all: all,
      active: active
    }
  end

  @impl true
  def get_product(basket_storage_id, product_id) do
    GenServer.call(
      ServerBasket.whereis(basket_storage_id),
      {:get_product, product_id}
    )
  end

  @impl true
  def update_product(basket_storage_id, product_id, amount) do
    GenServer.cast(
      ServerBasket.whereis(basket_storage_id),
      {:update_product, product_id, amount}
    )
  end

  @impl true
  def remove_product(basket_storage_id, product_id) do
    GenServer.cast(
      ServerBasket.whereis(basket_storage_id),
      {:remove_product, product_id}
    )
  end

  ###############
  # SERVER

  ###############
  # PRIVATE

  def whereis do
    GenServer.whereis(__MODULE__)
  end

  defp config do
    Application.get_env(:binshop, Binshop.Baskets.Server)
  end
end

defmodule Binshop.Baskets do
  @moduledoc """

  """

  @behaviour Binshop.Baskets.Storage

  alias Binshop.Baskets.Storage.Basket
  alias Binshop.Products

  @impl true
  def exists?(nil), do: false

  def exists?(basket_storage_id) do
    storage().exists?(basket_storage_id)
  end

  @impl true
  def create() do
    storage().create()
  end

  @impl true
  def get(nil), do: nil

  def get(basket_storage_id) do
    storage().get(basket_storage_id)
  end

  @impl true
  def delete(basket_storage_id) do
    storage().delete(basket_storage_id)
  end

  @impl true
  def get_product(basket_storage_id, product_id) do
    storage().get_product(basket_storage_id, product_id)
  end

  @impl true
  def update_product(basket_storage_id, product_id, amount) do
    storage().update_product(basket_storage_id, product_id, amount)
  end

  @impl true
  def remove_product(basket_storage_id, product_id) do
    storage().remove_product(basket_storage_id, product_id)
  end

  def get_products(%Basket{} = basket) do
    basket.items
    |> Enum.reject(fn {_, amount} -> amount == 0 end)
    |> Enum.map(fn {key, _} -> key end)
    |> Products.public_list_products_by_ids()
    |> Map.get(:entries)
    |> tap(&IO.inspect/1)
  end

  defp storage do
    Application.get_env(:binshop, Binshop.Baskets)
    |> Keyword.get(:storage)
  end
end

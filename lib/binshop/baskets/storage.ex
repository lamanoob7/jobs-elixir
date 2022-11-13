defmodule Binshop.Baskets.Storage do
  @moduledoc """
  Basket storage behaviour for poosible usage of more storages
  """

  alias Binshop.Baskets.Storage.{Basket, BasketItem}

  @type basket_storage_id :: binary()
  @type product_id :: binary()
  @type amount :: integer()
  @type reason :: binary()
  @type basket :: Basket.t()
  @type basket_item :: BasketItem.t()

  @doc "Create basket in storage."
  @callback exists?(basket_storage_id) :: boolean()

  @doc "Create basket in storage."
  @callback create() :: {:ok, basket} | {:error, reason}

  @doc "Get basket data from storage."
  @callback get(basket_storage_id) :: {:ok, basket} | {:error, reason}

  @doc "Delete basket data from storage."
  @callback delete(basket_storage_id) :: {:ok, basket} | {:error, reason}

  @doc "Get product amount from basket storage."
  @callback get_product(basket_storage_id, product_id) :: amount | nil | {:error, reason}

  @doc "Set/update product amount into basket storage."
  @callback update_product(basket_storage_id, product_id, amount) :: :ok | {:error, reason}

  @doc "Remove product into basket storage."
  @callback remove_product(basket_storage_id, product_id) :: :ok | {:error, reason}
end

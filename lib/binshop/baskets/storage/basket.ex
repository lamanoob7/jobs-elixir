defmodule Binshop.Baskets.Storage.Basket do
  @moduledoc """
  Struct representing a single customer basket
  """

  use TypedStruct

  alias Binshop.Products.Product

  typedstruct do
    @typedoc "Single storage basket entity"

    field :basket_storage_id, String.t()
    field :created_at, DateTime.t()
    field :updated_at, DateTime.t()
    field :keep_alive, non_neg_integer() | nil
    field :items, map(), default: %{}
    field :items_amount, non_neg_integer(), default: 0

    field :products, [Product], default: []
  end
end

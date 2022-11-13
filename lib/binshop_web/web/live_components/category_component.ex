defmodule BinshopWeb.Components.CategoryComponent do
  @moduledoc """
  Category live form component
  """
  use BinshopWeb, :live_component

  alias BinshopWeb.Router.Helpers, as: Routes
  alias Surface.Components.LiveRedirect

  prop category, :struct, required: true

  # @impl true
  # def mount(socket) do
  #   {:ok, socket}
  # end
end

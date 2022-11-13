defmodule BinshopWeb.Web.CategoryLive.Index do
  @moduledoc """
  Default live page module
  """
  use BinshopWeb, :live_view

  alias Binshop.Categories

  @impl true
  def mount(_params, _session, socket) do
    {categories, paginate} = list_categories(socket)

    {:ok,
     socket
     |> assign(:categories, categories)
     |> assign(:paginate, paginate)
     |> assign(:page_title, "Categories")}
  end

  ##############
  # Private
  defp list_categories(_socket, _opts \\ []) do
    Categories.list_categories(sort: "name", page: 1, page_size: 10)
    |> Map.pop(:entries)
  end
end

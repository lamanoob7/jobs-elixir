defmodule BinshopWeb.Components.PaginatorComponent do
  @moduledoc """
  Category live form component
  """
  use BinshopWeb, :live_component

  alias Surface.Components.LivePatch

  prop route, :fun
  prop paginate, :struct

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :pagination_sizes, [5, 10, 20, 30, 50])}
  end

  def update(assigns, socket) do
    beginning = [1, assigns.paginate.page_number - 2] |> Enum.max()
    ending = [assigns.paginate.page_number + 3, assigns.paginate.total_pages] |> Enum.min()

    {:ok,
     socket
     |> assign(:beginning, beginning)
     |> assign(:ending, ending)
     |> assign(:paginate, assigns.paginate)
     |> assign(:route, assigns.route)}
  end
end

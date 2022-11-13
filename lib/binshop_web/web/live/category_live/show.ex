defmodule BinshopWeb.Web.CategoryLive.Show do
  @moduledoc """
  Category live show modul
  """
  use BinshopWeb, :live_view

  alias Binshop.Categories

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    category = Categories.get_category_by_slug!(slug, preload_products: true)

    {:ok,
     socket
     |> assign(:category, category)
     |> assign(:page_title, "Category #{category.name}")}
  end
end

defmodule BinshopWeb.Admin.ProductCategoryLive.FormComponent do
  @moduledoc """
  Product Category live add/edit form modul
  """
  use BinshopWeb, :live_component

  alias Binshop.Categories
  alias Binshop.Products

  alias Surface.Components.Form
  alias Surface.Components.Form.{ErrorTag, Field, HiddenInput, Label, Select, Submit}

  prop product_category, :struct
  prop category, :struct
  prop product, :struct

  prop set_category, :boolean
  prop set_product, :boolean

  prop action, :string
  prop title, :string
  prop return_to, :string, required: true

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:categories, Categories.categories_for_select())
      |> assign(:products, Products.products_for_select())
      |> assign(:set_category, nil)
      |> assign(:set_product, nil)

    {:ok, socket}
  end

  @impl true
  def update(%{product_category: product_category} = assigns, socket) do
    changeset = Products.change_product_category(product_category)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"product_category" => product_category_params}, socket) do
    changeset =
      socket.assigns.product_category
      |> Products.change_product_category(product_category_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"product_category" => product_category_params}, socket) do
    save_product_category(socket, socket.assigns.action, product_category_params)
  end

  defp save_product_category(socket, :edit, product_category_params) do
    case Products.update_product_category(
           socket.assigns.product_category,
           product_category_params
         ) do
      {:ok, _product_category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product category updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_product_category(socket, :new, product_category_params) do
    case Products.create_product_category(product_category_params) do
      {:ok, _product_category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product category created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

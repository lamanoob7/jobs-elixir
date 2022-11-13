defmodule BinshopWeb.Admin.ProductLive.FormComponent do
  @moduledoc """
  Product live form component
  """
  use BinshopWeb, :live_component

  alias Binshop.Media
  alias Binshop.Products
  alias Surface.Components.{Form, LiveFileInput}

  alias Surface.Components.Form.{
    Checkbox,
    ErrorTag,
    Field,
    Label,
    NumberInput,
    Submit,
    TextArea,
    TextInput
  }

  prop action, :string
  prop title, :string
  prop product, :struct
  prop return_to, :string, required: true

  @impl true
  def mount(socket) do
    socket =
      socket
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png), max_entries: 1)
      |> assign(:uploaded_files, [])

    {:ok, socket}
  end

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Products.change_product(product)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      socket.assigns.product
      |> Products.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  defp save_product(socket, :edit, product_params) do
    product_params = put_image_to_params(socket, product_params)

    case Products.update_product(socket.assigns.product, product_params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_product(socket, :new, product_params) do
    product_params = put_image_to_params(socket, product_params)

    case Products.create_product(product_params) do
      {:ok, _product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp put_image_to_params(socket, params) do
    uploaded_files =
      consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
        {:ok, new_file_path} =
          "#{entry.uuid}.#{ext(entry)}"
          |> get_file_path()

        {:ok, _uploaded_file_path} = Media.upload_photo(path, filename: new_file_path)

        new_file_path
      end)

    params |> Map.put("image", List.first(uploaded_files))
  end

  defp ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  defp get_file_path(uploaded_filename) do
    case Media.check_image_filename?(uploaded_filename) do
      true ->
        image_extension = Path.extname(uploaded_filename)
        {:ok, "uploads/products/" <> UUID.uuid4() <> image_extension}

      any ->
        {:error, any}
    end
  end
end

defmodule BinshopWeb.Admin.CategoryLive.FormComponent do
  @moduledoc """
  Category live form component
  """
  use BinshopWeb, :live_component

  alias Binshop.Categories
  alias Binshop.Media

  alias Surface.Components.{Form, LiveFileInput}

  alias Surface.Components.Form.{
    Checkbox,
    ErrorTag,
    Field,
    Label,
    Submit,
    TextArea,
    TextInput
  }

  prop action, :string
  prop title, :string
  prop category, :struct
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
  def update(%{category: category} = assigns, socket) do
    changeset = Categories.change_category(category)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    changeset =
      socket.assigns.category
      |> Categories.change_category(category_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    save_category(socket, socket.assigns.action, category_params)
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  defp save_category(socket, :edit, category_params) do
    category_params = put_image_to_params(socket, category_params)

    case Categories.update_category(socket.assigns.category, category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_category(socket, :new, category_params) do
    category_params = put_image_to_params(socket, category_params)

    case Categories.create_category(category_params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category created successfully")
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

    image =
      case List.first(uploaded_files) do
        nil -> socket.assigns.category.image
        any -> any
      end

    params |> Map.put("image", image)
  end

  defp ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  defp get_file_path(uploaded_filename) do
    case Media.check_image_filename?(uploaded_filename) do
      true ->
        image_extension = Path.extname(uploaded_filename)
        {:ok, "uploads/categories/" <> UUID.uuid4() <> image_extension}

      any ->
        {:error, any}
    end
  end
end

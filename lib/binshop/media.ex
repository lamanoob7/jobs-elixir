defmodule Binshop.Media do
  @moduledoc """
  Context for handling operations related to Media files handling.
  """

  alias MIME
  alias String

  require Logger

  @doc "Provides URL for video upload."
  def upload_photo(file_path, opts \\ []) do
    {:ok, uploaded_file_path} = storage().upload_file(file_path, opts)

    {:ok, new_file_path} =
      storage().move_uploaded_file(:photo, uploaded_file_path, uploaded_file_path)

    storage().delete_uploaded_file(uploaded_file_path)
    {:ok, new_file_path}
  end

  def path_photo(file_path) when is_binary(file_path) do
    storage().get_photo_public_url(file_path)
  end

  def path_photo(nil), do: nil

  def check_image_extension?(image_extension) do
    mime_type = MIME.type(image_extension)
    String.match?(mime_type, ~r/image\/*/)
  end

  def check_image_filename?(filename) do
    mime_type = MIME.from_path(filename)
    String.match?(mime_type, ~r/image\/*/)
  end

  ###################
  # Implemented
  @doc "Provides URL for video upload."
  def upload_file(file_path, opts \\ []) do
    storage().upload_file(file_path, opts)
  end

  @doc "Returns `true` if the given filename exists on the storage."
  def uploaded_file_exists?(filename) do
    storage().file_exists?(filename)
  end

  @doc "Fetches metadata associated with the file."
  def get_metadata(filename) do
    storage().get_file_metadata(filename)
  end

  @doc "Stores metadata associated with the file."
  def store_metadata(metadata, filename) do
    storage().store_file_metadata(metadata, filename)
  end

  @doc "Permanently deletes file from the storage."
  def delete_uploaded_file(filename) do
    storage().delete_file(filename)
  end

  ####################
  # Private functions
  defp storage do
    Application.get_env(:binshop, Binshop.Media)[:storage]
  end
end

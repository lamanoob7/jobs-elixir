defmodule Binshop.Media.Storage do
  @moduledoc "Behavior for implementing specific storage for Media."

  defmodule Metadata do
    @moduledoc "This module defines struct for metadata."
    defstruct title: nil,
              description: nil,
              user_id: nil,
              last_modified: nil,
              original_name: nil,
              size_in_bytes: nil,
              mime_type: nil
  end

  @type file_path :: String.t()
  @type reason :: String.t()
  @type filename :: String.t()
  @type metadata :: %Metadata{}

  @type filepath :: String.t()
  @type public_url :: String.t() | nil
  @type file_type :: atom()

  @doc "Provides URL for uploading new video."
  @callback upload_file(file_path, keyword()) :: {:ok, file_path} | {:error, reason}

  @doc "Provides URL for uploading new video."
  @callback move_uploaded_file(file_type, file_path, file_path) ::
              {:ok, file_path} | {:error, reason}

  @doc "Returns `true` if the given filename exists on the storage."
  @callback uploaded_file_exists?(filename) :: boolean

  @doc "Fetches metadata associated with the file."
  @callback get_file_metadata(filename) :: {:ok, metadata}

  @doc "Stores metadata associated with the file."
  @callback store_file_metadata(metadata, filename) :: {:ok, metadata} | {:error, reason}

  @doc "Permanently deletes file from the storage."
  @callback delete_uploaded_file(filename) :: :ok | {:error, reason}

  @doc "Provides URL for post-processed media file."
  @callback get_media_public_url(filepath) :: public_url

  @doc "Provides URL for post-processed photo."
  @callback get_photo_public_url(filepath) :: public_url
end

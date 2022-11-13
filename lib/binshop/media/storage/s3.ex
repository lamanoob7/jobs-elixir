defmodule Binshop.Media.Storage.S3 do
  @moduledoc "Media storage implemented on top of amazon AWS S3."

  @behaviour Binshop.Media.Storage

  alias Binshop.Media.Storage.Metadata
  alias ExAws.S3
  alias File
  alias String

  require Logger

  @impl true
  # sobelow_skip ["Traversal"]
  def upload_file(file_path, opts \\ []) do
    upload_url = Keyword.get(opts, :filename, "files/#{UUID.uuid4()}.file")

    upload_bucket = upload_bucket()
    media_content = File.read!(file_path)

    Logger.debug("Upload s3 media file #{upload_url} into #{upload_bucket}")

    # Upload to S3
    {:ok, _response} =
      S3.put_object(upload_bucket, upload_url, media_content)
      |> ExAws.request()

    {:ok, upload_url}
  rescue
    error ->
      Logger.error([
        "Uploading of media file failed",
        "\n Error: #{Exception.format(:error, error, __STACKTRACE__)}"
      ])

      {:error, error.message}
  end

  @impl true
  def move_uploaded_file(:photo, old_path, new_path) do
    aws_response =
      S3.put_object_copy(media_bucket(), new_path, upload_bucket(), old_path) |> ExAws.request()

    case aws_response do
      {:ok, _} ->
        {:ok, new_path}

      any ->
        Logger.debug(inspect(any))
        {:error, "Error while moving photo '#{old_path}' -> '#{new_path}'."}
    end
  end

  @impl true
  def uploaded_file_exists?(filename) do
    Logger.debug("Performed existence check on uploaded #{filename}")
    response = upload_bucket() |> S3.head_object(filename) |> ExAws.request()

    case response do
      {:ok, _} -> true
      _ -> false
    end
  end

  @impl true
  def get_file_metadata(filename) do
    Logger.debug("Accessed #{filename} metadata")

    case upload_bucket() |> S3.head_object(filename) |> ExAws.request() do
      {:ok, %{headers: headers}} ->
        headers_map = Map.new(headers)
        title = Map.get(headers_map, "x-amz-meta-title")
        description = Map.get(headers_map, "x-amz-meta-description")
        user_id = Map.get(headers_map, "x-amz-meta-user-id")
        last_modified = Map.get(headers_map, "x-amz-meta-last-modified")
        original_name = Map.get(headers_map, "x-amz-meta-original-name")
        size_in_bytes = Map.get(headers_map, "x-amz-meta-size-in-bytes")
        mime_type = Map.get(headers_map, "x-amz-meta-mime-type")

        metadata = %Metadata{
          title: title,
          description: description,
          user_id: user_id,
          last_modified: last_modified,
          original_name: original_name,
          size_in_bytes: size_in_bytes,
          mime_type: mime_type
        }

        {:ok, metadata}

      _ ->
        {:error, "Error getting '#{filename}' metadata."}
    end
  end

  @impl true
  def store_file_metadata(%Metadata{} = metadata, filename) do
    last_modified =
      case metadata.last_modified do
        %DateTime{} = d -> DateTime.to_iso8601(d)
        no_date -> no_date
      end

    meta =
      [
        {"title", metadata.title},
        {"description", metadata.description},
        {"user-id", metadata.user_id},
        {"last-modified", last_modified},
        {"original-name", metadata.original_name},
        {"size-in-bytes", metadata.size_in_bytes},
        {"mime-type", metadata.mime_type}
      ]
      |> Enum.filter(fn {_, v} -> not is_nil(v) end)

    aws_response =
      upload_bucket()
      |> S3.put_object_copy(filename, upload_bucket(), filename,
        meta: meta,
        metadata_directive: :REPLACE
      )
      |> ExAws.request()

    case aws_response do
      {:ok, _} ->
        Logger.debug(["Stored #{filename} metadata", "\n Metadata: #{inspect(metadata)}"])
        {:ok, metadata}

      error ->
        Logger.error(["Storing metadata of #{filename} failed", "\n Error: #{inspect(error)}"])
        {:error, "Storing metadata of #{filename} failed"}
    end
  end

  @impl true
  def delete_uploaded_file(filename) do
    aws_response = upload_bucket() |> S3.delete_object(filename) |> ExAws.request()

    case aws_response do
      {:ok, _} -> :ok
      _ -> {:error, "Error while deleting '#{filename}'."}
    end
  end

  @impl true
  def get_media_public_url(filepath) do
    %{scheme: scheme, port: port, host: host} = ExAws.Config.new(:s3)
    "#{scheme}#{media_bucket()}.#{host}:#{port}/#{filepath}"
  end

  @impl true
  def get_photo_public_url(filepath) do
    get_media_public_url(filepath)
  end

  defp media_bucket do
    Application.get_env(:binshop, Binshop.Media.Storage.S3)[:media_bucket]
  end

  defp upload_bucket do
    Application.get_env(:binshop, Binshop.Media.Storage.S3)[:upload_bucket]
  end
end

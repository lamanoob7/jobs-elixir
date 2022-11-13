defmodule BinshopWeb.Common.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  import BinshopWeb.Gettext

  alias Ecto.UUID

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error),
        class: "invalid-feedback",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(BinshopWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(BinshopWeb.Gettext, "errors", msg, opts)
    end
  end

  defmodule JSONAPIErrorSource do
    @moduledoc "Represents a JSON:API compliant error source."
    @derive {Jason.Encoder, only: [:pointer, :parameter]}
    defstruct [:pointer, :parameter]
  end

  defmodule JSONAPIError do
    @moduledoc "Represents a JSON:API compliant error."
    @derive {Jason.Encoder, only: [:id, :status, :code, :title, :detail, :source]}
    defstruct [:id, :status, :code, :title, :detail, source: %JSONAPIErrorSource{}]
  end

  @doc """
  Generates struct of errors from invalid changeset that is translatable to json.
  """
  def error_messages(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Map.to_list()
    |> Enum.map(fn {field, errors} ->
      json_error(field, errors)
    end)
  end

  defp json_error(field, errors) when is_map(errors) do
    %JSONAPIError{
      id: UUID.generate(),
      title: dgettext("errors", "%{field} validation error", field: field),
      status: "422",
      code: "422",
      detail: errors |> get_errors(),
      source: %JSONAPIErrorSource{
        pointer: "/data/attributes/#{field}"
      }
    }
  end

  defp json_error(field, errors) when is_list(errors) do
    %JSONAPIError{
      id: UUID.generate(),
      title: dgettext("errors", "%{field} validation error", field: field),
      status: "422",
      code: "422",
      detail: errors |> Enum.join(","),
      source: %JSONAPIErrorSource{
        pointer: "/data/attributes/#{field}"
      }
    }
  end

  defp get_errors(errors) do
    errors
    |> get_errors_as_list()
    |> Enum.map(fn {k, v} -> "#{k}: #{v |> Enum.join(",")}" end)
    |> Enum.join("; ")
  end

  defp get_errors_as_list(errors, keys \\ []) do
    Enum.reduce(errors, [], fn {k, v}, acc ->
      new_keys = keys ++ [Atom.to_string(k)]

      result =
        case v do
          %{} ->
            get_errors_as_list(v, new_keys)

          _ ->
            [{new_keys |> Enum.join("."), v}]
        end

      acc ++ result
    end)
  end
end

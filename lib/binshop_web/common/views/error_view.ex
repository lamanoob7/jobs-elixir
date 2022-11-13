defmodule BinshopWeb.Common.ErrorView do
  use BinshopWeb, :view_common

  import BinshopWeb.Gettext

  alias Ecto.UUID

  def render("400.json", assigns) do
    error = %JSONAPIError{
      id: Map.get(assigns, :id, UUID.generate()),
      title: Map.get(assigns, :title, "Bad Request"),
      status: Map.get(assigns, :status, "400"),
      code: Map.get(assigns, :code, "400"),
      detail:
        Map.get(
          assigns,
          :detail,
          dgettext(
            "errors",
            "Server cannot or will not process the request due to something that is perceived to be a client error (e.g., malformed request syntax, invalid request message framing, or deceptive request routing)."
          )
        ),
      source: %JSONAPIErrorSource{
        pointer: Map.get(assigns, :source_pointer),
        parameter: Map.get(assigns, :source_parameter)
      }
    }

    %{"errors" => [render_one(error, __MODULE__, "error.json")]}
  end

  def render("401.json", assigns) do
    error = %JSONAPIError{
      id: Map.get(assigns, :id, UUID.generate()),
      title: Map.get(assigns, :title, dgettext("errors", "Unauthorized")),
      status: Map.get(assigns, :status, "401"),
      code: Map.get(assigns, :code, "401"),
      detail:
        Map.get(
          assigns,
          :detail,
          dgettext(
            "errors",
            "Request has not been applied because it lacks valid authentication credentials for the target resource."
          )
        ),
      source: %JSONAPIErrorSource{
        pointer: Map.get(assigns, :source_pointer),
        parameter: Map.get(assigns, :source_parameter)
      }
    }

    %{"errors" => [render_one(error, __MODULE__, "error.json")]}
  end

  def render("403.json", assigns) do
    error = %JSONAPIError{
      id: Map.get(assigns, :id, UUID.generate()),
      title: Map.get(assigns, :title, dgettext("errors", "Forbidden")),
      status: Map.get(assigns, :status, "403"),
      code: Map.get(assigns, :code, "403"),
      detail:
        Map.get(
          assigns,
          :detail,
          dgettext("errors", "Server understood the request but refuses to authorize it.")
        ),
      source: %JSONAPIErrorSource{
        pointer: Map.get(assigns, :source_pointer),
        parameter: Map.get(assigns, :source_parameter)
      }
    }

    %{"errors" => [render_one(error, __MODULE__, "error.json")]}
  end

  def render("404.json", assigns) do
    error = %JSONAPIError{
      id: Map.get(assigns, :id, UUID.generate()),
      title: Map.get(assigns, :title, dgettext("errors", "Not Found")),
      status: Map.get(assigns, :status, "404"),
      code: Map.get(assigns, :code, "404"),
      detail:
        Map.get(assigns, :detail, dgettext("errors", "Server can't find the requested resource.")),
      source: %JSONAPIErrorSource{
        pointer: Map.get(assigns, :source_pointer),
        parameter: Map.get(assigns, :source_parameter)
      }
    }

    %{"errors" => [render_one(error, __MODULE__, "error.json")]}
  end

  def render("422.json", assigns) do
    error = %JSONAPIError{
      id: Map.get(assigns, :id, UUID.generate()),
      title: Map.get(assigns, :title, dgettext("errors", "Unprocessable Entity")),
      status: Map.get(assigns, :status, "422"),
      code: Map.get(assigns, :code, "422"),
      detail:
        Map.get(
          assigns,
          :detail,
          dgettext("errors", "Unable to process the contained instructions.")
        ),
      source: %JSONAPIErrorSource{
        pointer: Map.get(assigns, :source_pointer),
        parameter: Map.get(assigns, :source_parameter)
      }
    }

    %{"errors" => [render_one(error, __MODULE__, "error.json")]}
  end

  def render("500.json", assigns) do
    error = %JSONAPIError{
      id: Map.get(assigns, :id, UUID.generate()),
      title: Map.get(assigns, :title, dgettext("errors", "Internal Server Error")),
      status: Map.get(assigns, :status, "500"),
      code: Map.get(assigns, :code, "500"),
      detail:
        Map.get(
          assigns,
          :detail,
          dgettext(
            "errors",
            "Server encountered an unexpected condition that prevented it from fulfilling the request."
          )
        ),
      source: %JSONAPIErrorSource{
        pointer: Map.get(assigns, :source_pointer),
        parameter: Map.get(assigns, :source_parameter)
      }
    }

    %{"errors" => [render_one(error, __MODULE__, "error.json")]}
  end

  def render("error.json", %{error: %JSONAPIError{} = error}) do
    %{
      "id" => error.id,
      "title" => error.title,
      "status" => error.status,
      "code" => error.code,
      "detail" => error.detail,
      "source" => %{
        "pointer" => error.source.pointer,
        "parameter" => error.source.parameter
      }
    }
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, assigns) do
    status = template |> String.split(".") |> hd()
    title = Phoenix.Controller.status_message_from_template(template)

    error = %JSONAPIError{
      id: Map.get(assigns, :id, UUID.generate()),
      title: Map.get(assigns, :title, title),
      status: Map.get(assigns, :status, status),
      code: Map.get(assigns, :code, status),
      detail: Map.get(assigns, :detail, dgettext("errors", "Internal error in response engine.")),
      source: %JSONAPIErrorSource{
        pointer: Map.get(assigns, :source_pointer),
        parameter: Map.get(assigns, :source_parameter)
      }
    }

    %{"errors" => [render_one(error, __MODULE__, "error.json")]}
  end
end

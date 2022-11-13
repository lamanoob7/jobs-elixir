defmodule BinshopWeb.Web.LiveHelpers do
  @moduledoc """
  Live helper component
  """

  def get_value(socket, opts, name, default_value \\ nil) when is_atom(name) do
    Keyword.get(
      opts,
      name,
      Map.get(socket.assigns, name, default_value)
    )
  end
end

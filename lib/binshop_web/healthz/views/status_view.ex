defmodule BinshopWeb.Healthz.StatusView do
  use BinshopWeb, :view

  require Logger

  def render("index.json", _) do
    %{"data" => "ok"}
  end
end

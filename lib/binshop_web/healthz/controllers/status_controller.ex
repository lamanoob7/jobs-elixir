defmodule BinshopWeb.Healthz.StatusController do
  @moduledoc tags: ["Healthz"]

  use BinshopWeb, :controller

  def liveness(conn, _params) do
    conn
    |> put_status(:ok)
    |> render(:index)
  end

  def readiness(conn, _params) do
    conn
    |> put_status(:ok)
    |> render(:index)
  end
end

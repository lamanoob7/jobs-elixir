defmodule BinshopWeb.Common.ControllerHelpers do
  @moduledoc """
  Conveniences for building controllers.
  """
  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [put_view: 2, render: 3]

  alias BinshopWeb.Common.ErrorView

  @doc "Utility function for rendering general Bad Request error."
  def render_bad_request(conn, assigns \\ []) do
    conn |> put_status(:bad_request) |> put_view(ErrorView) |> render(:"400", assigns)
  end

  @doc "Utility function for rendering general Unauthorized error."
  def render_unauthorized(conn, assigns \\ []) do
    conn
    |> put_status(:unauthorized)
    |> put_view(ErrorView)
    |> render(:"401", assigns)
  end

  @doc "Utility function for rendering general Forbidden error."
  def render_forbidden(conn, assigns \\ []) do
    conn |> put_status(:forbidden) |> put_view(ErrorView) |> render(:"403", assigns)
  end

  @doc "Utility function for rendering general Not Found error."
  def render_not_found(conn, assigns \\ []) do
    conn |> put_status(:not_found) |> put_view(ErrorView) |> render(:"404", assigns)
  end

  @doc "Utility function for rendering general Unprocessable Entity error."
  def render_unprocessable_entity(conn, assigns \\ []) do
    conn |> put_status(:unprocessable_entity) |> put_view(ErrorView) |> render(:"422", assigns)
  end

  @doc "Utility function for rendering general Internal Server Error."
  def render_internal_server_error(conn, assigns \\ []) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(ErrorView)
    |> render(:"500", assigns)
  end
end

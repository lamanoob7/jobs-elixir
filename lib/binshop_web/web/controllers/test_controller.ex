defmodule BinshopWeb.Web.TestController do
  @moduledoc tags: ["Admin Testing"]

  use BinshopWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> render(:index)
  end

  def bad_request(conn, _params) do
    conn
    |> render_bad_request()
  end

  def unauthorized(conn, _params) do
    conn
    |> render_unauthorized()
  end

  def forbidden(conn, _params) do
    conn
    |> render_forbidden()
  end

  def not_found(conn, _params) do
    conn
    |> render_not_found()
  end

  def unprocessable_entity(conn, _params) do
    conn
    |> render_unprocessable_entity()
  end

  def internal_server_error(conn, _params) do
    conn
    |> render_internal_server_error()
  end
end

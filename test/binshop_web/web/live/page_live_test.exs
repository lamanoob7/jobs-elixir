defmodule BinshopWeb.PageLiveTest do
  use BinshopWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to our Binshop!"
    assert render(page_live) =~ "Welcome to our Binshop!"
  end
end

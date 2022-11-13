defmodule BinshopWeb.Admin.PageLiveTest do
  use BinshopWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Administration homepage unlogged" do
    test "should return error", %{conn: conn} do
      {:error, {:redirect, %{flash: _, to: "/auth"}}} = live(conn, "/admin")
    end
  end

  describe "Administration homepage logged" do
    setup [:register_and_log_in_user]

    test "should disconnected and connected render", %{conn: conn} do
      {:ok, page_live, disconnected_html} = live(conn, "/admin")
      assert disconnected_html =~ "Welcome to administration of Binshop!"
      assert render(page_live) =~ "Welcome to administration of Binshop!"
    end
  end
end

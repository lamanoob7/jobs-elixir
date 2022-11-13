defmodule BinshopWeb.Plugs.EnsureBasketSession do
  @moduledoc """
  This plug is responsible for authenticate by token in query
  """
  import Plug.Conn

  @behaviour Plug

  @basket_storage_id_assign :basket_storage_id
  @basket_storage_id_session "_binshop_web_basket_storage_id"

  @impl Plug
  def init(opts \\ []), do: opts

  @impl Plug
  def call(conn, _opts) do
    processed_conn =
      conn
      |> get_session(@basket_storage_id_session)
      |> case do
        nil ->
          create_basket_storage(conn)

        basket_storage_id ->
          Binshop.Baskets.exists?(basket_storage_id)
          |> case do
            true ->
              conn

            false ->
              conn
              |> delete_session(@basket_storage_id_session)
              |> create_basket_storage()
          end
      end

    basket_storage_id = get_session(processed_conn, @basket_storage_id_session)

    processed_conn |> assign(@basket_storage_id_assign, basket_storage_id)
  end

  defp create_basket_storage(conn) do
    {:ok, %{basket_storage_id: created_basket_storage_id}} = Binshop.Baskets.create()

    put_session(conn, @basket_storage_id_session, created_basket_storage_id)
  end

  def basket_storage_id_assign do
    @basket_storage_id_assign
  end
end

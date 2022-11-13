defmodule BinshopWeb.Plugs.EnsureBasket do
  @moduledoc """
  This plug is responsible for authenticate by token in query
  """
  import Plug.Conn

  @behaviour Plug

  @max_age 60 * 60 * 24 * 7
  @basket_storage_id_assign :basket_storage_id
  @basket_storage_id_cookie "_binshop_web_basket_storage_id"
  @basket_storage_id_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @impl Plug
  def init(opts \\ []), do: opts

  @impl Plug
  def call(conn, _opts) do
    fetched_conn =
      conn
      |> fetch_cookies(signed: [@basket_storage_id_cookie])

    processed_conn =
      fetched_conn
      |> Map.get(:cookies)
      |> Map.get(@basket_storage_id_cookie)
      |> case do
        nil ->
          create_basket_storage(fetched_conn)

        basket_storage_id ->
          IO.inspect(basket_storage_id)

          Binshop.Baskets.exists?(basket_storage_id)
          |> case do
            true ->
              fetched_conn

            false ->
              fetched_conn
              |> delete_resp_cookie(@basket_storage_id_cookie)
              |> create_basket_storage()
          end
      end

    basket_storage_id = processed_conn.cookies[@basket_storage_id_cookie]

    processed_conn |> assign(@basket_storage_id_assign, basket_storage_id)
  end

  defp create_basket_storage(conn) do
    {:ok, %{basket_storage_id: created_basket_storage_id}} = Binshop.Baskets.create()

    conn
    |> put_resp_cookie(
      @basket_storage_id_cookie,
      created_basket_storage_id,
      @basket_storage_id_options
    )
  end

  def basket_storage_id_assign do
    @basket_storage_id_assign
  end
end

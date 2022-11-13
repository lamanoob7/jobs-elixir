defmodule BinshopWeb.Auth.UserLiveAuth do
  @moduledoc "When user logged use user_token and load current user and insert into assigns"
  import Phoenix.LiveView

  alias Binshop.Accounts

  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        Accounts.get_user_by_session_token(user_token)
      end)

    {:cont, socket}
  end

  def mount(_params, _session, socket),
    do: {:cont, assign(socket, :current_user, nil)}
end

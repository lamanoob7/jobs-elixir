defmodule BinshopWeb.Auth.AuthController do
  use BinshopWeb, :controller

  plug Ueberauth

  alias Binshop.Accounts
  alias Binshop.Accounts.Auth.DataParser
  alias Binshop.Accounts.{User, UserAuthProvider}
  alias BinshopWeb.Auth.UserAuth
  alias BinshopWeb.Router.Helpers, as: RouterHelpers
  alias Ueberauth.Strategy.Helpers

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  @doc "Callback route for all provider strategies except :identity"
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case auth
         |> DataParser.ueberauth_data()
         |> Accounts.set_role(:user)
         |> UserAuth.process_provider_user() do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> UserAuth.log_in_user(user)

      {:error, :already_defined_user_provider} ->
        conn
        |> put_flash(
          :error,
          "For allowing to login over new provider, please sign in using one of already registered providers and connect new provider. "
        )
        |> render_unauthorized()
    end
  end

  @doc """
    When coming to specific provider, render view
    When coming without specific provider redirect to identity request
  """
  def request(conn, %{"provider" => _}) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn), error_message: nil)
  end

  def request(conn, _params) do
    redirect(conn, to: RouterHelpers.auth_path(conn, :request, :identity))
  end

  @doc "Identity provider is used ONLY for log in, registration is in stand alone controller"
  def identity_callback(
        %{
          assigns: %{
            ueberauth_auth: %{
              credentials: %{other: %{password: password}},
              info: %{email: email}
            }
          }
        } = conn,
        _params
      ) do
    with {:provider, %UserAuthProvider{} = user_auth_provider} <-
           {:provider, Accounts.get_user_auth_provider_by_email_and_password(email, password)},
         {:user, %User{} = user} <- {:user, Accounts.get_user!(user_auth_provider.user_id)},
         {:email, true} <- {:email, Accounts.email_confirmed?(user)} do
      conn
      |> put_flash(:info, "Successfully authenticated.")
      |> UserAuth.log_in_user(user)
    else
      {key, _} ->
        identity_callback_errors(conn, key)
    end
  end

  defp identity_callback_errors(conn, error_key) do
    conn
    |> put_flash(
      :error,
      case error_key do
        :provider ->
          "Credentials not valid. Check your email or renew forgotten password."

        :user ->
          "Credentials not valid. Check your email or renew forgotten password."

        :email ->
          "Email is not confirmed yet. Please check your email or resend new email confirmation request."
      end
    )
    |> redirect(to: RouterHelpers.auth_path(conn, :request, :identity))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end

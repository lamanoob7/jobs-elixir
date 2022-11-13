defmodule BinshopWeb.Auth.UserSettingsController do
  use BinshopWeb, :controller

  alias Binshop.Accounts
  alias BinshopWeb.Auth.UserAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"current_password" => password, "user" => user_params} = params
    user = conn.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          user.email,
          &Routes.user_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def update(
        conn,
        %{
          "action" => "update_password",
          "current_password" => password,
          "password" => password_params
        } = _params
      ) do
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, password_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, :no_identity_provider} ->
        conn
        |> put_flash(
          :error,
          "Login using email and password not setup. Please add it in your settings."
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, password_changeset} ->
        render(conn, "edit.html",
          password_changeset: %{password_changeset | action: :update_password}
        )
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(
      :password_changeset,
      Accounts.change_user_password(%Binshop.Accounts.Auth.Password{})
    )
  end
end

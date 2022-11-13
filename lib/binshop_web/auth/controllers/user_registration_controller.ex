defmodule BinshopWeb.Auth.UserRegistrationController do
  use BinshopWeb, :controller

  alias Binshop.Accounts
  alias Binshop.Accounts.{User, UserTempRegistration}
  alias BinshopWeb.Auth.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_temp_registration(%UserTempRegistration{})
    render(conn, "new.html", changeset: changeset)
  end

  def request(conn, %{"user_temp_registration" => params}) do
    case Accounts.create_temp_registration(params) do
      {:ok, {user_temp_registration, token}} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user_temp_registration,
            &Routes.user_registration_url(conn, :confirm, &1),
            token
          )

        conn
        |> put_flash(:info, "User created successfully. Please confirm your email before log in.")
        |> redirect(to: Routes.user_registration_path(conn, :pending))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: %{changeset | action: :update_password})
    end
  end

  def pending(conn, _params) do
    render(conn, "pending.html")
  end

  def confirm(conn, %{"token" => user_temp_registration_token}) do
    case Accounts.get_user_temp_registration_by_token(user_temp_registration_token) do
      {:ok, %UserTempRegistration{} = user_temp_registration} ->
        changeset = Accounts.change_user_registration(%User{})

        render(conn, "confirm.html",
          changeset: changeset,
          token: user_temp_registration_token,
          email: user_temp_registration.email
        )

      {:error, _} ->
        conn
        |> put_flash(:error, "User Email confirmation link is invalid or it has expired.")
        |> redirect(to: Routes.user_registration_path(conn, :new))
    end
  end

  def create(conn, %{"token" => token, "user" => user_params}) do
    with {:token, {:ok, %UserTempRegistration{} = user_temp_registration}} <-
           {:token, Accounts.get_user_temp_registration_by_token(token)},
         {:email, user_params} <-
           {:email, Map.put(user_params, "email", user_temp_registration.email)},
         {:user, {:ok, %{user: user}}, user_temp_registration} <-
           {:user, Accounts.register_user_and_profile(user_params), user_temp_registration} do
      Accounts.delete_temp_registration(user_temp_registration)

      conn
      |> put_flash(:info, "User created successfully.")
      |> put_session(:user_return_to, Routes.user_registration_path(conn, :created))
      |> UserAuth.log_in_user(user)
    else
      {:token, _} ->
        conn
        |> put_flash(:error, "User Email confirmation link is invalid or it has expired.")
        |> redirect(to: Routes.user_registration_path(conn, :new))

      {:email, _} ->
        conn
        |> put_flash(:error, "User Email confirmation link is invalid or it has expired.")
        |> redirect(to: Routes.user_registration_path(conn, :new))

      {:user, {:error, :user, %Ecto.Changeset{} = changeset, _}, user_temp_registration} ->
        render(conn, "confirm.html",
          changeset: changeset,
          token: token,
          email: user_temp_registration.email
        )

      {:user, {:error, :user_profile, %Ecto.Changeset{} = changeset, _}, user_temp_registration} ->
        render(conn, "confirm.html",
          changeset: changeset,
          token: token,
          email: user_temp_registration.email
        )
    end
  end

  def created(conn, _params) do
    render(conn, "created.html")
  end
end

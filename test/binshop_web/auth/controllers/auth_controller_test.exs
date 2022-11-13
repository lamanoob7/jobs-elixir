defmodule BinshopWeb.AuthControllerTest do
  use BinshopWeb.ConnCase, async: true

  import Binshop.AccountsFixtures

  alias Binshop.Accounts.Auth.Password
  alias Binshop.Accounts.{User, UserAuthProvider, UserProfile}
  alias Binshop.Repo
  alias BinshopWeb.Auth.AuthController

  setup do
    %{user: user_fixture()}
  end

  describe "request/2" do
    test "without provider should redirect to identity request", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :request))

      assert "/auth/identity" == conn |> redirected_to(302)
    end

    test "with provider should render form and other providers", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :request, :identity))

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in with username / password</h1>"
      assert response =~ "email"
      assert response =~ "password"
      assert response =~ "Login"
      assert response =~ "Facebook"
      assert response =~ "Google"
    end
  end

  describe "callback/2" do
    test "should callback succeeds", %{conn: conn} do
      auth = %Ueberauth.Auth{
        uid: "ueberauth_google_test_uid",
        provider: :google,
        info: %{
          first_name: "John",
          last_name: "Doe",
          email: "john.doe@example.com",
          image: "https://example.com/image.jpg",
          role: :user
        }
      }

      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> fetch_flash()
        |> bypass_through(BinshopWeb.Router, [:browser])
        |> assign(:ueberauth_auth, auth)
        |> AuthController.callback(%{})

      assert "/" == conn |> redirected_to(302)
      assert get_flash(conn, :info) == "Successfully authenticated."

      assert %User{} = user = Repo.get_by(User, email: "john.doe@example.com")

      assert %UserAuthProvider{} =
               user_auth_provider =
               Repo.get_by(UserAuthProvider,
                 provider: :google,
                 subject_id: "ueberauth_google_test_uid"
               )

      assert user.id === user_auth_provider.user_id

      assert %UserProfile{
               first_name: "John",
               last_name: "Doe",
               picture: "https://example.com/image.jpg"
             } = Repo.get_by(UserProfile, user_id: user.id)
    end

    test "should callback fails", %{conn: conn} do
      failure =
        struct(
          Ueberauth.Failure,
          provider: "provider_name",
          strategy: "strategy",
          errors: %{}
        )

      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> fetch_session()
        |> fetch_flash()
        |> bypass_through(BinshopWeb.Router, [:browser])
        |> assign(:ueberauth_failure, failure)
        |> AuthController.callback(%{})

      assert "/" == conn |> redirected_to(302)
      assert get_flash(conn, :error) == "Failed to authenticate."
    end
  end

  describe "identity_callback/2 as login" do
    setup context do
      %{user: user} = create_user(context)

      user_data = %{password: valid_user_password()}

      {:ok, %User{} = new_user} =
        user
        |> Password.changeset(user_data)
        |> Repo.update()

      %{user: new_user}
    end

    test "should callback succeeds", %{conn: conn, user: user} do
      user_data = %{confirmed_at: DateTime.utc_now()}

      %UserAuthProvider{} = user_auth_provider_fixture(user)

      {:ok, %User{} = new_user} =
        user
        |> User.changeset(user_data)
        |> Repo.update()

      assert new_user.confirmed_at !== nil

      auth = %Ueberauth.Auth{
        provider: :google,
        credentials: %{other: %{password: valid_user_password()}},
        info: %{
          email: "userjohn@doe.com"
        }
      }

      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> fetch_flash()
        |> bypass_through(BinshopWeb.Router, [:browser])
        |> assign(:ueberauth_auth, auth)
        |> AuthController.identity_callback(%{})

      assert "/" == conn |> redirected_to(302)
      assert get_flash(conn, :info) == "Successfully authenticated."
    end

    test "should callback fails on password verification", %{conn: conn, user: user} do
      user_data = %{confirmed_at: DateTime.utc_now()}

      %UserAuthProvider{} = user_auth_provider_fixture(user)

      {:ok, %User{} = new_user} =
        user
        |> User.changeset(user_data)
        |> Repo.update()

      assert new_user.confirmed_at !== nil

      auth = %Ueberauth.Auth{
        provider: :google,
        credentials: %{other: %{password: "bad_password"}},
        info: %{
          email: "userjohn@doe.com"
        }
      }

      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> fetch_session()
        |> fetch_flash()
        |> bypass_through(BinshopWeb.Router, [:browser])
        |> assign(:ueberauth_auth, auth)
        |> AuthController.identity_callback(%{})

      assert "/auth/identity" == conn |> redirected_to(302)

      assert get_flash(conn, :error) ==
               "Credentials not valid. Check your email or renew forgotten password."
    end

    test "should callback fails on not existing user", %{conn: conn, user: user} do
      user_data = %{confirmed_at: DateTime.utc_now()}

      %UserAuthProvider{} = user_auth_provider_fixture(user)

      {:ok, %User{} = new_user} =
        user
        |> User.changeset(user_data)
        |> Repo.update()

      assert new_user.confirmed_at !== nil

      auth = %Ueberauth.Auth{
        provider: :google,
        credentials: %{other: %{password: valid_user_password()}},
        info: %{
          email: "not_existing_user@doe.com"
        }
      }

      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> fetch_session()
        |> fetch_flash()
        |> bypass_through(BinshopWeb.Router, [:browser])
        |> assign(:ueberauth_auth, auth)
        |> AuthController.identity_callback(%{})

      assert "/auth/identity" == conn |> redirected_to(302)

      assert get_flash(conn, :error) ==
               "Credentials not valid. Check your email or renew forgotten password."
    end

    test "should callback fails on not confirmed user", %{conn: conn, user: user} do
      assert user.confirmed_at === nil

      %UserAuthProvider{} = user_auth_provider_fixture(user)

      auth = %Ueberauth.Auth{
        provider: :google,
        credentials: %{other: %{password: valid_user_password()}},
        info: %{
          email: "userjohn@doe.com"
        }
      }

      conn =
        conn
        |> Plug.Test.init_test_session(%{})
        |> fetch_session()
        |> fetch_flash()
        |> bypass_through(BinshopWeb.Router, [:browser])
        |> assign(:ueberauth_auth, auth)
        |> AuthController.identity_callback(%{})

      assert "/auth/identity" == conn |> redirected_to(302)

      assert get_flash(conn, :error) ==
               "Email is not confirmed yet. Please check your email or resend new email confirmation request."
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(Routes.auth_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.auth_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end

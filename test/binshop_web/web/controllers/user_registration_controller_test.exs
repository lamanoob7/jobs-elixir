defmodule BinshopWeb.UserRegistrationControllerTest do
  use BinshopWeb.ConnCase, async: true

  import Binshop.AccountsFixtures

  alias Binshop.Accounts.{User, UserProfile, UserTempRegistration}
  alias Binshop.Repo

  describe "GET /users/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "Log in</a>"
      assert response =~ "Register</a>"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get(Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "creates account and logs the user in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, Routes.user_registration_path(conn, :request), %{
          "user_temp_registration" => valid_user_attributes(email: email)
        })

      assert nil === get_session(conn, :user_token)
      redirect_uri = redirected_to(conn)
      assert redirect_uri =~ Routes.user_registration_path(conn, :pending)

      # Check after registration redirect page
      conn = get(conn, redirect_uri)
      response = html_response(conn, 200)
      assert !String.contains?(response, email)
      assert response =~ "User created successfully. Please confirm your email before log in."
      assert response =~ "Log in</a>"
      assert response =~ "Register</a>"
      assert response =~ "Registration pending"
      assert response =~ "Resend confirmation instructions"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert !String.contains?(response, email)
      assert response =~ "Log in</a>"
      assert response =~ "Register</a>"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :request), %{
          "user_temp_registration" => %{
            "email" => "with spaces"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "must have the @ sign and no spaces"
    end

    test "render errors for already registered email", %{conn: conn} do
      email = unique_user_email()
      _existing_user = user_fixture(%{email: email})

      conn =
        post(conn, Routes.user_registration_path(conn, :request), %{
          "user_temp_registration" => valid_user_attributes(email: email)
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "Email is already registered"
    end
  end

  describe "GET /users/register/:token" do
    @tag :capture_log
    test "with valid data should response with registration form step two", %{conn: conn} do
      {token, user_temp_registration} = create_temp_registration()

      conn = get(conn, Routes.user_registration_path(conn, :confirm, token))

      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "Email"
      assert response =~ user_temp_registration.email
      assert response =~ "First name"
      assert response =~ "Last name"
      assert response =~ "Log in"
      assert response =~ "Forgot your password?"
    end
  end

  describe "POST /users/register/:token" do
    @tag :capture_log
    test "with valid data should response with registration form step two", %{conn: conn} do
      {token, user_temp_registration} = create_temp_registration()
      email = user_temp_registration.email

      conn =
        post(conn, Routes.user_registration_path(conn, :confirm, token), %{
          "user" => %{
            first_name: "first name",
            last_name: "last name",
            password: "testing password"
          }
        })

      assert nil !== get_session(conn, :user_token)
      assert redirected_to(conn) =~ Routes.user_registration_path(conn, :created)

      %User{} = user = Repo.get_by(User, email: email)
      assert user.email == email
      %UserProfile{} = user_profile = Repo.get_by(UserProfile, user_id: user.id)
      assert user_profile.first_name == "first name"
      assert user_profile.last_name == "last name"

      # Now do a logged in request and assert on the menu
      conn = get(conn, Routes.user_registration_path(conn, :created))
      response = html_response(conn, 200)
      assert String.contains?(response, email)
      assert response =~ "Log out</a>"
      assert response =~ "Settings</a>"
      assert response =~ user.email
    end

    test "with invalid token should response ", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :confirm, "invalid_token"), %{
          "user" => %{
            first_name: "first name",
            last_name: "last name",
            password: "testing password"
          }
        })

      assert nil === get_session(conn, :user_token)
      assert redirected_to(conn) =~ Routes.user_registration_path(conn, :new)
    end

    test "with short password should return form error", %{conn: conn} do
      {token, _} = create_temp_registration()

      conn =
        post(conn, Routes.user_registration_path(conn, :confirm, token), %{
          "user" => %{
            first_name: "first name",
            last_name: "last name",
            password: "short pass"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "should be at least 12 character(s)"
    end
  end

  defp create_temp_registration do
    {token, user_temp_registration} = UserTempRegistration.build_hashed_token()

    {:ok, user_temp_registration} =
      %{user_temp_registration | email: unique_user_email()}
      |> Repo.insert()

    {token, user_temp_registration}
  end
end

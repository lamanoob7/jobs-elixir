defmodule BinshopWeb.Auth.UserAuthTest do
  use BinshopWeb.ConnCase, async: true

  alias Binshop.Accounts.{User, UserAuthProvider}
  alias BinshopWeb.Auth.UserAuth

  describe "process_provider_user/2 no existing user" do
    test "with valid data should return return ok & user" do
      user_data = %{
        email: "test_email@testgoogle.test",
        picture: "http://test_picture_url.testgoogle.test",
        provider: :google,
        subject_id: "test_google_subject_id",
        first_name: "test_google_first_name",
        last_name: "test_google_last_name",
        role: :user
      }

      assert {:ok, %User{}} = UserAuth.process_provider_user(user_data)
    end

    test "with missing email should raise error" do
      user_data = %{
        picture: "http://test_picture_url.testgoogle.test",
        provider: :google,
        subject_id: "test_google_subject_id",
        first_name: "test_google_first_name",
        last_name: "test_google_last_name",
        role: :user
      }

      assert_raise FunctionClauseError, fn ->
        UserAuth.process_provider_user(user_data)
      end
    end
  end

  describe "process_provider_user/2 existing user" do
    setup [:create_user, :create_auth_provider]

    test "with valid data and same provider should return return ok & user", %{
      user: user,
      user_auth_provider: user_auth_provider
    } do
      assert %User{
               email: "userjohn@doe.com"
             } = user

      assert %UserAuthProvider{
               provider: :identity,
               subject_id: "UserAuthProviderSubjectId"
             } = user_auth_provider

      user_data = %{
        email: "userjohn@doe.com",
        picture: "http://test_picture_url.testgoogle.test",
        provider: :identity,
        subject_id: "UserAuthProviderSubjectId",
        first_name: "test_google_first_name",
        last_name: "test_google_last_name",
        role: :user
      }

      assert {:ok, %User{}} = UserAuth.process_provider_user(user_data)
    end

    test "with invalid data and same provider should return return ok & user", %{
      user: user,
      user_auth_provider: user_auth_provider
    } do
      assert %User{
               email: "userjohn@doe.com"
             } = user

      assert %UserAuthProvider{
               provider: :identity,
               subject_id: "UserAuthProviderSubjectId"
             } = user_auth_provider

      user_data = %{
        email: "userjohn@doe.com",
        picture: "http://test_picture_url.testgoogle.test",
        provider: :identity,
        subject_id: "DifferentUserAuthSubjectId",
        first_name: "test_google_first_name",
        last_name: "test_google_last_name",
        role: :user
      }

      assert {:error, :already_defined_user_provider} = UserAuth.process_provider_user(user_data)
    end
  end

  describe "get_valid_provider_user/2 with existing user" do
    setup [:create_user]

    test "should return error already_defined_user_provider", %{
      user: user
    } do
      assert %User{
               email: "userjohn@doe.com"
             } = user

      data = %{email: "userjohn@doe.com"}

      assert {:error, :already_defined_user_provider} = UserAuth.get_valid_provider_user(data)
    end
  end

  describe "get_valid_provider_user/2 not existing user" do
    test "with valid data should return user" do
      data = %{
        email: "test_email@testgoogle.test",
        picture: "http://test_picture_url.testgoogle.test",
        provider: :google,
        subject_id: "test_google_subject_id",
        first_name: "test_google_first_name",
        last_name: "test_google_last_name",
        role: :user
      }

      assert {:ok, %User{}} = UserAuth.get_valid_provider_user(data)
    end
  end
end

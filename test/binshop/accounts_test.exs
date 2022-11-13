defmodule Binshop.AccountsTest do
  use Binshop.DataCase

  import Binshop.AccountsFixtures

  alias Binshop.Accounts
  alias Binshop.Accounts.Auth.Password
  alias Binshop.Accounts.{User, UserAuthProvider, UserProfile, UserToken}

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      %UserAuthProvider{} = user_auth_provider_fixture(user)
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = user_fixture()
      %UserAuthProvider{} = user_auth_provider_fixture(user)

      assert %User{id: ^id} =
               Accounts.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!("11111111-1111-1111-1111-111111111111")
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = user_fixture()
      {:error, changeset} = Accounts.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers users with a hashed password" do
      email = unique_user_email()
      {:ok, user} = Accounts.register_user(valid_user_attributes(email: email))
      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "change_user_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_user_email()
      password = valid_user_password()

      changeset =
        Accounts.change_user_registration(
          %User{},
          valid_user_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_user_email/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_user_email/3" do
    setup do
      %{user: user_fixture()}
    end

    test "requires email to change", %{user: user} do
      {:error, changeset} = Accounts.apply_user_email(user, valid_user_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{user: user} do
      %{email: email} = user_fixture()

      {:error, changeset} =
        Accounts.apply_user_email(user, valid_user_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.apply_user_email(user, "invalid", %{email: unique_user_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{user: user} do
      email = unique_user_email()
      {:ok, user} = Accounts.apply_user_email(user, valid_user_password(), %{email: email})
      assert user.email == email
      assert Accounts.get_user!(user.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup do
      user = user_fixture()
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{user: user, token: token, email: email}
    end

    test "updates the email with a valid token", %{user: user, token: token, email: email} do
      assert Accounts.update_user_email(user, token) == :ok
      changed_user = Repo.get!(User, user.id)
      assert changed_user.email != user.email
      assert changed_user.email == email
      assert changed_user.confirmed_at
      assert changed_user.confirmed_at != user.confirmed_at
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email with invalid token", %{user: user} do
      assert Accounts.update_user_email(user, "oops") == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if user email changed", %{user: user, token: token} do
      assert Accounts.update_user_email(%{user | email: "current@example.com"}, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_user_email(user, token) == :error
      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/2" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_user_password(%User{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/3" do
    setup do
      %User{} = user = user_fixture()
      %UserAuthProvider{} = user_auth_provider = user_auth_provider_fixture(user)
      %{user: user, user_auth_provider: user_auth_provider}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_user_password(user, valid_user_password(), %{password: too_long})

      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{user: user} do
      {:error, changeset} =
        Accounts.update_user_password(user, "invalid", %{password: valid_user_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{user: user, user_auth_provider: user_auth_provider} do
      assert Password.valid_password?(user_auth_provider, valid_user_password())

      {:ok, new_user_auth_provider} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      assert Password.valid_password?(new_user_auth_provider, "new valid password")
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)

      {:ok, _} =
        Accounts.update_user_password(user, valid_user_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "update_user_password/3 no identity provider" do
    setup do
      %{user: user_fixture()}
    end

    test "should return error", %{user: user} do
      assert {:error, :no_identity_provider} =
               Accounts.update_user_password(user, valid_user_password(), %{
                 password: valid_user_password(),
                 password_confirmation: valid_user_password()
               })
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "deliver_user_confirmation_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "confirm"
    end
  end

  describe "deliver_user_reset_password_instructions/2" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "reset_password"
    end
  end

  describe "get_user_by_reset_password_token/1" do
    setup do
      user = user_fixture()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{user: user, token: token}
    end

    test "returns the user with valid token", %{user: %{id: id}, token: token} do
      assert %User{id: ^id} = Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: id)
    end

    test "does not return the user with invalid token", %{user: user} do
      refute Accounts.get_user_by_reset_password_token("oops")
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not return the user if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_reset_password_token(token)
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "reset_user_password/2" do
    setup do
      %User{} = user = user_fixture()
      %UserAuthProvider{} = user_auth_provider_fixture(user)
      %{user: user}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Accounts.reset_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_user_password(user, %{password: too_long})
      assert "should be at most 80 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, updated_user_auth_provider} =
        Accounts.reset_user_password(user, %{password: "new valid password"})

      assert false === Map.has_key?(updated_user_auth_provider.data, :password)
      assert false === Map.has_key?(updated_user_auth_provider.data, "password")
      assert Map.has_key?(updated_user_auth_provider.data, "hashed_password")
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Accounts.generate_user_session_token(user)
      {:ok, _} = Accounts.reset_user_password(user, %{password: "new valid password"})
      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "create_user/2" do
    test "should create user" do
      assert nil === Repo.get_by(User, email: "test_email@testgoogle.test")

      user_data = %{
        email: "test_email@testgoogle.test",
        picture: "http://test_picture_url.testgoogle.test",
        provider: :google,
        subject_id: "test_google_subject_id",
        first_name: "test_google_first_name",
        last_name: "test_google_last_name",
        role: :user
      }

      assert {:ok, %User{} = user} = Accounts.create_user(user_data)

      assert %User{
               id: user_id,
               email: "test_email@testgoogle.test",
               role: :user
             } = user

      assert {:ok, _user_uuid} = ShortUUID.decode(user_id)
      assert %User{} = Repo.get_by(User, email: "test_email@testgoogle.test")
    end
  end

  describe "update_user/2" do
    setup [:create_user]

    test "should create user", %{user: user} do
      assert %User{
               email: "userjohn@doe.com",
               role: :user
             } = user

      user_new_data = %{
        email: "new_user_email@doe.com",
        role: :user
      }

      assert {:ok, %User{} = updated_user} = Accounts.update_user(user, user_new_data)

      assert %User{
               id: user_id,
               email: "new_user_email@doe.com",
               role: :user
             } = updated_user

      assert {:ok, _user_uuid} = ShortUUID.decode(user_id)

      assert %User{
               email: "new_user_email@doe.com",
               role: :user
             } = Repo.get_by(User, id: user_id)
    end
  end

  describe "update_auth_provider/2" do
    setup [:create_user, :create_auth_provider]

    test "should create user", %{
      user_auth_provider: user_auth_provider
    } do
      assert %UserAuthProvider{
               provider: :identity,
               subject_id: "UserAuthProviderSubjectId"
             } = user_auth_provider

      new_data = %{
        subject_id: "NewUserAuthProviderSubjectId"
      }

      assert {:ok, %UserAuthProvider{} = updated_user_auth_provider} =
               Accounts.update_auth_provider(user_auth_provider, new_data)

      assert %UserAuthProvider{
               provider: :identity,
               subject_id: "NewUserAuthProviderSubjectId"
             } = updated_user_auth_provider

      assert %UserAuthProvider{
               provider: :identity,
               subject_id: "NewUserAuthProviderSubjectId"
             } =
               Repo.get_by(UserAuthProvider,
                 provider: :identity,
                 subject_id: "NewUserAuthProviderSubjectId"
               )
    end
  end

  describe "create_profile/2" do
    setup [:create_user]

    test "should create user profile with filled values", %{user: user} do
      data = %{
        first_name: "first name",
        last_name: "last name",
        picture: "picture_url"
      }

      assert {:ok, user_profile} = Accounts.create_profile(user, data)

      assert %{
               first_name: "first name",
               last_name: "last name",
               picture: "picture_url"
             } = user_profile
    end

    test "should create user profile with empty values", %{user: user} do
      data = %{
        first_name: "",
        last_name: "",
        picture: ""
      }

      assert {:ok, user_profile} = Accounts.create_profile(user, data)

      assert %{
               first_name: nil,
               last_name: nil,
               picture: nil
             } = user_profile
    end
  end

  describe "update_profile/2" do
    setup [:create_user]

    test "should update user profile", %{user: user} do
      %UserProfile{user_id: user_profile_user_id} = user_profile = user_profile_fixture(user)

      assert user_profile_user_id == user.id

      assert %{
               first_name: "first name",
               last_name: "last name",
               picture: "picture_url"
             } = user_profile

      new_data = %{
        first_name: "new first name",
        last_name: "new last name",
        picture: "new_picture_url"
      }

      {:ok, new_user_profile} = Accounts.update_profile(user_profile, new_data)

      assert %{
               first_name: "new first name",
               last_name: "new last name",
               picture: "new_picture_url"
             } = new_user_profile
    end
  end

  describe "ensure_user/2 create" do
    test "should create user" do
      assert nil === Repo.get_by(User, email: "test_email@testgoogle.test")

      user_data = %{
        email: "test_email@testgoogle.test",
        picture: "http://test_picture_url.testgoogle.test",
        provider: :google,
        subject_id: "test_google_subject_id",
        first_name: "test_google_first_name",
        last_name: "test_google_last_name",
        role: :user
      }

      assert {:ok, %User{} = user} = Accounts.ensure_user(user_data)

      assert %User{
               id: user_id,
               email: "test_email@testgoogle.test",
               role: :user
             } = user

      assert {:ok, _user_uuid} = ShortUUID.decode(user_id)
      assert %User{} = Repo.get_by(User, email: "test_email@testgoogle.test")
    end
  end

  describe "ensure_user/2 update" do
    setup [:create_user, :create_auth_provider]

    test "with same email should return existing user", %{user: user} do
      assert %User{
               email: "userjohn@doe.com",
               role: :user
             } = user

      user_new_data = %{
        email: "userjohn@doe.com",
        role: :user
      }

      assert {:ok, %User{} = updated_user} = Accounts.ensure_user(user_new_data)

      assert %User{
               id: user_id,
               email: "userjohn@doe.com",
               role: :user
             } = updated_user

      assert {:ok, _user_uuid} = ShortUUID.decode(user_id)

      assert %User{
               email: "userjohn@doe.com",
               role: :user
             } = Repo.get_by(User, id: user_id)
    end

    test "with different email should create new user and must contain full data", %{user: user} do
      assert %User{
               email: "userjohn@doe.com",
               role: :user
             } = user

      user_new_data = %{
        email: "new_user_email@doe.com",
        picture: "http://test_picture_url.testgoogle.test",
        provider: :google,
        subject_id: "test_google_subject_id",
        first_name: "test_google_first_name",
        last_name: "test_google_last_name",
        role: :user
      }

      assert {:ok, %User{} = updated_user} = Accounts.ensure_user(user_new_data)

      assert %User{
               id: user_id,
               email: "new_user_email@doe.com",
               role: :user
             } = updated_user

      assert {:ok, _user_uuid} = ShortUUID.decode(user_id)
      assert user.id != user_id

      assert %User{
               email: "new_user_email@doe.com",
               role: :user
             } = Repo.get_by(User, id: user_id)
    end
  end

  describe "set_role/2 update" do
    setup [:create_user]

    test "with valid role should return user with new role", %{user: user} do
      assert %User{
               email: "userjohn@doe.com",
               role: :user
             } = user

      assert %User{role: :admin} = Accounts.set_role(user, :admin)
    end

    test "with disallowed role should raise error FunctionClauseError", %{user: user} do
      assert %User{
               email: "userjohn@doe.com",
               role: :user
             } = user

      assert_raise FunctionClauseError, fn ->
        Accounts.set_role(user, :bad_role)
      end
    end
  end

  describe "get_user_auth_provider/2 when user auth provider exist" do
    setup [:create_user]

    test "should return provider", %{user: user} do
      assert %{
               user_auth_provider:
                 %UserAuthProvider{
                   provider: :identity,
                   subject_id: "UserAuthProviderSubjectId"
                 } = _user_auth_provider
             } = create_auth_provider(%{user: user})

      assert %UserAuthProvider{
               provider: :identity,
               subject_id: "UserAuthProviderSubjectId"
             } = Accounts.get_user_auth_provider(:identity, "UserAuthProviderSubjectId")
    end
  end

  describe "get_user_auth_provider/2 when user auth provider does not exist" do
    test "should return nil" do
      assert nil === Accounts.get_user_auth_provider(:identity, "non_existing_subject_id")
    end
  end

  describe "get_user_auth_provider_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Accounts.get_user_auth_provider_by_email_and_password(
               "unknown@example.com",
               "hello world!"
             )
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture()
      %UserAuthProvider{} = user_auth_provider_fixture(user)
      refute Accounts.get_user_auth_provider_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = user_fixture()
      %UserAuthProvider{} = user_auth_provider_fixture(user)

      assert %UserAuthProvider{user_id: ^id} =
               Accounts.get_user_auth_provider_by_email_and_password(
                 user.email,
                 valid_user_password()
               )
    end
  end
end

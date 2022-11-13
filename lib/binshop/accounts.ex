defmodule Binshop.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Binshop.Accounts.Auth.Password

  alias Binshop.Accounts.{
    User,
    UserAuthProvider,
    UserNotifier,
    UserProfile,
    UserTempRegistration,
    UserToken
  }

  alias Binshop.Repo

  require Logger

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_auth_provider_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_auth_provider_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_auth_provider_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user_auth_provider = Repo.get_by(UserAuthProvider, subject_id: email, provider: :identity)
    if Password.valid_password?(user_auth_provider, password), do: user_auth_provider
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    with %UserAuthProvider{} = user_auth_provider <-
           get_user_auth_provider_by_email_and_password(email, password),
         %User{} = user <- get_user!(user_auth_provider.user_id),
         true <- Password.valid_password?(user_auth_provider, password) do
      user
    else
      any ->
        Logger.debug(inspect(any))
        nil
    end
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @spec register_provider_user(map()) ::
          {:ok, %{user: map(), user_auth_provider: map(), user_profile: map()}}
          | {:error, any()}
          | {:error, Ecto.Multi.name(), any(), %{required(Ecto.Multi.name()) => any()}}
  def register_provider_user(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:user, fn _repo, _ ->
      %User{}
      |> User.provider_registration_changeset(attrs)
      |> Repo.insert()
    end)
    |> Ecto.Multi.run(:user_auth_provider, fn _repo, %{user: %User{} = user} ->
      create_auth_provider(user, attrs)
    end)
    |> Ecto.Multi.run(:user_profile, fn _repo, %{user: %User{} = user} ->
      create_profile(user, attrs)
    end)
    |> Repo.transaction()
  end

  def register_user_and_profile(attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:user, fn _repo, _ ->
      register_user(attrs)
    end)
    |> Ecto.Multi.run(:user_auth_provider, fn _repo, %{user: %User{} = user} ->
      create_auth_provider(
        user,
        Enum.into(
          attrs,
          %{
            "provider" => :identity,
            "subject_id" => Map.get(attrs, "email"),
            "data" => %{
              hashed_password: Map.get(attrs, "password") |> Password.create_hashed_password()
            }
          }
        )
      )
    end)
    |> Ecto.Multi.run(:user_profile, fn _repo, %{user: user} ->
      create_profile(user, attrs)
    end)
    |> Repo.transaction()
  end

  def create_temp_registration(%{"email" => _} = attrs) do
    with {token, %UserTempRegistration{} = user_temp_registration} <-
           UserTempRegistration.build_hashed_token(),
         changeset <- UserTempRegistration.changeset(user_temp_registration, attrs),
         {:changeset, true, changeset} <- {:changeset, changeset.valid?, changeset},
         {:ok, saved_user_temp_registration} <-
           Repo.insert(changeset) do
      {:ok, {saved_user_temp_registration, token}}
    else
      {:changeset, false, changeset} -> {:error, changeset}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def change_user_temp_registration(
        %UserTempRegistration{} = user_temp_registration,
        attrs \\ %{}
      ) do
    UserTempRegistration.changeset(user_temp_registration, attrs)
  end

  def delete_temp_registration(%UserTempRegistration{} = user_temp_registration) do
    user_temp_registration
    |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> Password.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset = user |> User.email_changeset(%{email: email}) |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, [context]))
  end

  @doc """
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_update_email_instructions(user, current_email, &Routes.user_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(password, attrs \\ %{}) do
    Password.changeset(password, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    with {:user_auth_provider, %UserAuthProvider{} = user_auth_provider} <-
           {:user_auth_provider,
            get_user_auth_provider_by_provider_and_user_id(:identity, user.id)},
         {:password, password_changeset} <-
           {:password,
            %Password{hashed_password: Map.get(user_auth_provider.data, "hashed_password")}
            |> Password.changeset(attrs)
            |> Password.validate_current_password(password)},
         {:password, true, password_changeset} <-
           {:password, password_changeset.valid?, password_changeset} do
      update_valid_user_password(user, user_auth_provider, password_changeset)
    else
      {:user_auth_provider, nil} -> {:error, :no_identity_provider}
      {:password, false, password_changeset} -> {:error, password_changeset}
    end
  end

  defp update_valid_user_password(user, user_auth_provider, password_changeset) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :user_auth_provider,
      user_auth_provider
      |> UserAuthProvider.changeset(%{
        data: %{"hashed_password" => password_changeset.changes.hashed_password}
      })
    )
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user_auth_provider: user_auth_provider}} -> {:ok, user_auth_provider}
      {:error, :user_auth_provider, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UserToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &Routes.user_confirmation_url(conn, :confirm, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &Routes.user_confirmation_url(conn, :confirm, &1))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)

      UserNotifier.deliver_confirmation_instructions(
        user.email,
        confirmation_url_fun.(encoded_token)
      )
    end
  end

  def deliver_user_confirmation_instructions(
        %UserTempRegistration{} = user_temp_registration,
        confirmation_url_fun,
        decoded_token
      )
      when is_function(confirmation_url_fun, 1) and is_binary(user_temp_registration.email) do
    UserNotifier.deliver_confirmation_instructions(
      user_temp_registration.email,
      confirmation_url_fun.(decoded_token)
    )
  end

  @doc """
  Confirms user's email by the given token.

  If the token matches, the user is allowed to register new account
  and the token is deleted.
  """
  def get_user_temp_registration_by_token(token) do
    UserTempRegistration.verify_token_query(token)
  end

  def email_confirmed?(%{confirmed_at: confirmed_at}) do
    nil !== confirmed_at
  end

  def email_confirmed?(_), do: false

  ## Reset password

  @doc """
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &Routes.user_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    with {:user_auth_provider, %UserAuthProvider{} = user_auth_provider} <-
           {:user_auth_provider,
            get_user_auth_provider_by_provider_and_user_id(:identity, user.id)},
         {:password, password_changeset} <-
           {:password,
            %Password{hashed_password: Map.get(user_auth_provider.data, "hashed_password")}
            |> Password.changeset(attrs)},
         {:password, true, password_changeset} <-
           {:password, password_changeset.valid?, password_changeset} do
      reset_valid_user_password(user, user_auth_provider, password_changeset)
    else
      {:user_auth_provider, nil} -> {:error, :no_identity_provider}
      {:password, false, password_changeset} -> {:error, password_changeset}
    end
  end

  defp reset_valid_user_password(user, user_auth_provider, password_changeset) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :user_auth_provider,
      user_auth_provider
      |> UserAuthProvider.changeset(%{
        data: %{"hashed_password" => password_changeset.changes.hashed_password}
      })
    )
    |> Ecto.Multi.delete_all(:tokens, UserToken.user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user_auth_provider: user_auth_provider}} -> {:ok, user_auth_provider}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc "Creates new user and it's associated profile in RDBMS."
  def create_user(%{} = attrs) do
    result =
      %User{}
      |> User.provider_registration_changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, user} ->
        Logger.info([
          "Created new User(#{user.id}) with associated user profile and personal video channel",
          "\n  Attributes: #{inspect(attrs)}"
        ])

      {:error, changeset} ->
        Logger.error([
          "Creating of new user failed",
          "\n  Attributes: #{inspect(attrs)}",
          "\n  Changeset: #{inspect(changeset)}"
        ])
    end

    result
  end

  @doc "Updates user with provided attributes."
  def update_user(%User{} = user, attrs) do
    result =
      user
      |> User.provider_registration_changeset(attrs)
      |> Repo.update()

    case result do
      {:ok, _user} ->
        Logger.info("Updated User(#{user.id})")

      {:error, changeset} ->
        Logger.info([
          "Error while updating User(#{user.id})",
          "\n  Changeset: #{inspect(changeset)}"
        ])
    end

    result
  end

  def create_profile(%User{} = user, attrs) do
    %UserProfile{}
    |> UserProfile.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def create_auth_provider(%User{} = user, attrs) do
    %UserAuthProvider{}
    |> UserAuthProvider.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def update_auth_provider(%UserAuthProvider{} = user_auth_provider, attrs) do
    user_auth_provider
    |> UserAuthProvider.changeset(attrs)
    |> Repo.update()
  end

  def update_profile(%UserProfile{} = user_profile, attrs) do
    user_profile
    |> UserProfile.changeset(attrs)
    |> Repo.update()
  end

  def get_user_profile(%User{} = user) do
    Repo.get_by!(UserProfile, user_id: user.id)
  end

  @doc """
  Ensure user exists

  Used mainly in Ueberauth authorizations
  """
  def ensure_user(%{email: email} = user_data) do
    case get_user_by_email(email) do
      nil ->
        {:ok, %{user: user, user_auth_provider: _, user_profile: _}} =
          register_provider_user(user_data)

        {:ok, user}

      %User{} = user ->
        last_login = DateTime.utc_now()

        update_user(user, %{
          last_login: last_login
        })
    end
  end

  def set_role(user, role) when is_atom(role) and role in [:user, :admin] do
    Map.put(user, :role, role)
  end

  def get_user_auth_provider(provider, subject_id) when is_atom(provider) do
    Repo.get_by(UserAuthProvider, provider: provider, subject_id: subject_id)
  end

  def get_user_auth_provider_by_provider_and_user_id(provider, user_id) when is_atom(provider) do
    Repo.get_by(UserAuthProvider, provider: provider, user_id: user_id)
  end
end

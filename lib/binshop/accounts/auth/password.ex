defmodule Binshop.Accounts.Auth.Password do
  @moduledoc """
  Password schema and module for processing and validating password over Elixir.Account.{User, UserAuthProvider}
  """
  use Binshop.Schema

  import Ecto.Changeset

  alias Binshop.Accounts.Auth.Password
  alias Binshop.Accounts.{User, UserAuthProvider}

  embedded_schema do
    field :password, :string, virtual: true, null: true
    field :hashed_password, :string
  end

  def changeset(data, attrs, opts \\ []) do
    data
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ [])

  def password_changeset(%User{} = user, attrs, opts) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  def password_changeset(%Binshop.Accounts.Auth.Password{} = user_password, attrs, opts) do
    user_password
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  def validate_password(changeset, opts) do
    get_dynamic_password_validation_rules()
    |> apply_dynamic_password_validation_rules(changeset)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, create_hashed_password(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  def create_hashed_password(password) do
    Bcrypt.hash_pwd_salt(password)
  end

  @doc """
  Verifies the password for User and %UserAuthProvider{type: :identity}

  If there is no user auth provider or the user auth provider doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """

  def valid_password?(%User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(%UserAuthProvider{data: %{"hashed_password" => hashed_password}}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(%Password{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  defp get_dynamic_password_validation_rules do
    Application.get_env(:binshop, Binshop.Accounts.Auth.Password)
    |> Keyword.get(:rules)
  end

  defp apply_dynamic_password_validation_rules(rules, changeset) do
    Enum.reduce(rules, changeset, fn {mod, fun, params}, cset ->
      apply(mod, fun, [cset | params])
    end)
  end
end

defmodule Binshop.Accounts.User do
  @moduledoc """
  User schema
  """
  use Binshop.Schema

  import Ecto.Changeset

  alias Binshop.Accounts.Auth.Password

  @derive {Inspect, except: [:password]}
  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, null: true
    field :hashed_password, :string
    field :confirmed_at, :naive_datetime
    field :role, Ecto.Enum, values: [:user, :admin]

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_email()
    |> validate_password(opts)
  end

  def provider_registration_changeset(user, attrs, _opts \\ []) do
    user
    |> cast(attrs, [:email, :role])
    |> validate_email()
  end

  def changeset(user, attrs, _opts \\ []) do
    user
    |> cast(attrs, [
      :email,
      :hashed_password,
      :role,
      :confirmed_at
    ])
    |> validate_email()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, Binshop.Repo)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> Password.validate_password(opts)
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end
end

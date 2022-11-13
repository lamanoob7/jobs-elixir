defmodule Binshop.Accounts.UserTempRegistration do
  @moduledoc """
  User Temporary Registration token schema
  """
  use Binshop.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Binshop.Accounts.{User, UserTempRegistration}
  alias Binshop.Repo

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @confirm_validity_in_days 7

  schema "users_temp_registration" do
    field :email, :string
    field :token, :binary
    field :unhashed_token, :binary, virtual: true, null: true

    timestamps(updated_at: false)
  end

  def changeset(user_temp_registration, attrs) do
    user_temp_registration
    |> cast(attrs, [:email, :token])
    |> validate_email()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/,
      message: "must have the @ sign and no spaces"
    )
    |> validate_length(:email, max: 160)
    |> validate_unique_email()
  end

  def validate_unique_email(changeset) do
    email = get_field(changeset, :email)

    if is_nil(email) do
      changeset
    else
      case Repo.get_by(User, email: email) do
        nil ->
          changeset

        _ ->
          add_error(
            changeset,
            :email,
            "Email is already registered",
            validation: :validate_unique_email
          )
      end
    end
  end

  def build_hashed_token do
    token = generate_token()
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {
      Base.url_encode64(token, padding: false),
      %Binshop.Accounts.UserTempRegistration{
        token: hashed_token
      }
    }
  end

  defp generate_token do
    :crypto.strong_rand_bytes(@rand_size)
  end

  @doc """
  Builds a token with a hashed counter part.

  The non-hashed token is sent to the user email while the
  hashed part is stored in the database, to avoid reconstruction.
  The token is valid for a week as long as users don't change
  their email.
  """
  def hash_token(%UserTempRegistration{} = user_temp_registration)
      when is_binary(user_temp_registration.token) do
    user_temp_registration.token
  end

  def hash_token(token) do
    {:ok, Base.url_encode64(token, padding: false)}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token.
  """
  def verify_token_query(token) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context()

        query =
          from token in UserTempRegistration,
            where: [token: ^hashed_token],
            where: token.inserted_at > ago(^days, "day")

        case Repo.one(query) do
          %UserTempRegistration{} = user_temp_registration ->
            {:ok, user_temp_registration}

          _ ->
            {:error, :not_found}
        end

      :error ->
        {:error, :not_valid}
    end
  end

  defp days_for_context, do: @confirm_validity_in_days
end

defmodule Binshop.Accounts.UserAuthProvider do
  @moduledoc """
  User token schema
  """
  use Binshop.Schema

  import Ecto.Changeset

  @primary_key false
  schema "users_auth_providers" do
    field :provider, Ecto.Enum, values: [:apple, :facebook, :google, :identity], primary_key: true
    field :subject_id, :string, null: false, primary_key: true
    field :data, :map, null: true

    belongs_to :user, Binshop.Accounts.User

    timestamps()
  end

  @doc """
  Changeset of all attributes, that can be changed by user
  """
  def changeset(user_auth_provider, attrs) do
    user_auth_provider
    |> cast(attrs, [:provider, :subject_id, :data])
  end
end

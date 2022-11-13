defmodule Binshop.Accounts.UserProfile do
  @moduledoc """
  User token schema
  """
  use Binshop.Schema

  import Ecto.Changeset

  @primary_key false
  schema "users_profiles" do
    field :first_name, :string, null: true
    field :last_name, :string, null: true
    field :picture, :string, null: true

    belongs_to :user, Binshop.Accounts.User, primary_key: true

    timestamps(inserted_at: false)
  end

  @doc """
  Changeset of all attributes, that can be changed by user
  """
  def changeset(user_profile, attrs) do
    user_profile
    |> cast(attrs, [:first_name, :last_name, :picture])
  end
end

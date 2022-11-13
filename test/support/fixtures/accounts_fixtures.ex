defmodule Binshop.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Binshop.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_hashed_password,
    do: "$2b$04$bvRXr42tTX22kVm2QTf.1uyx0OhpcXrS7WROz0PCiajFbCIlnkV/m"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def valid_user_profile_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      first_name: "first name",
      last_name: "last name",
      picture: "picture_url"
    })
  end

  def valid_user_auth_provider_identity_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      provider: :identity,
      subject_id: "test1@test.test",
      data: %{"hashed_password" => valid_user_hashed_password(), password: valid_user_password()}
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Binshop.Accounts.register_user()

    user
  end

  def user_profile_fixture(user, attrs \\ %{}) do
    {:ok, user_profile} =
      Binshop.Accounts.create_profile(user, valid_user_profile_attributes(attrs))

    user_profile
  end

  def user_auth_provider_fixture(user, attrs \\ %{}) do
    {:ok, user_auth_provider} =
      Binshop.Accounts.create_auth_provider(
        user,
        valid_user_auth_provider_identity_attributes(
          attrs
          |> Map.merge(%{subject_id: user.email})
        )
      )

    user_auth_provider
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end

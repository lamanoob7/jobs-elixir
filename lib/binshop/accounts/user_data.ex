defmodule Binshop.Accounts.UserData do
  @moduledoc """
  Module for unifying data for creating admin.
  """

  alias Binshop.Accounts.Auth.UeberauthData

  # Preparing data from Google using Ueberauth strategy
  def prepare_data(%{} = auth_data) do
    UeberauthData.prepare_data(auth_data)
    |> Map.put(:role, :user)
  end
end

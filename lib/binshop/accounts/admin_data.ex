defmodule Binshop.Accounts.AdminData do
  @moduledoc """
  Module for user data.
  """

  alias Binshop.Accounts.Auth.UeberauthData

  # Preparing data from Google using Ueberauth strategy
  def prepare_data(%{} = auth_data) do
    UeberauthData.prepare_data(auth_data)
    |> Map.put(:role, :admin)
  end
end

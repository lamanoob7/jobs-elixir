defmodule Binshop.Accounts.Auth.UeberauthData do
  @moduledoc """
  Module for unifying data for creating admin.
  """

  # Preparing data from Google using Ueberauth strategy
  def prepare_data(%{info: %{email: email} = info, provider: provider}) do
    %{
      email: email,
      picture: Map.get(info, :image),
      subject_claim: provider,
      first_name: Map.get(info, :first_name),
      last_name: Map.get(info, :last_name)
    }
  end
end

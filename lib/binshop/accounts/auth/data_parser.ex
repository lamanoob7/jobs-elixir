defmodule Binshop.Accounts.Auth.DataParser do
  @moduledoc """
  Module for unifying data for creating admin.
  """

  # Preparing data from Google using Ueberauth strategy
  def ueberauth_data(%{info: %{email: email} = info, provider: provider, uid: subject_id}) do
    %{
      email: email,
      picture: Map.get(info, :image),
      provider: provider,
      subject_id: subject_id,
      first_name: Map.get(info, :first_name),
      last_name: Map.get(info, :last_name)
    }
  end
end

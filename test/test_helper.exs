# We should load application first, to get access to it’s specification.
Application.load(:binshop)

# List all the applications, which are dependencies. Then just ensure, that they are all started.
for app <- Application.spec(:binshop, :applications) do
  Application.ensure_all_started(app)
end

# Start supervision tree of core systems.
Supervisor.start_link(
  [
    # Start the Ecto repository
    Binshop.Repo,
    # Start the endpoint when the application starts
    BinshopWeb.Endpoint
  ],
  strategy: :one_for_one,
  name: Binshop.Supervisor
)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Binshop.Repo, :manual)

defmodule BinshopWeb.TestHelpers do
  @moduledoc """
  Helpers for tests.

  This module concentrates all testings patterns to make the tests code DRY.
  """

  alias Binshop.Accounts.{User, UserAuthProvider}
  alias Binshop.Repo
  alias Plug.Conn.Status

  @doc "Returns true if JSON:API error is of specific HTTP status code."
  def is_json_api_error(response, code) when is_atom(code) do
    status_code = code |> Status.code() |> to_string()

    with %{"errors" => [error | _]} <- response,
         %{"code" => ^status_code, "status" => ^status_code} <- error do
      true
    else
      _ -> false
    end
  end

  def create_user(_context, attrs \\ %{}) do
    user_data =
      Map.merge(
        %{
          first_name: "UserJohn",
          last_name: "UserDoe",
          email: "userjohn@doe.com",
          role: :user
        },
        attrs
      )

    {:ok, %User{} = user} = Repo.insert(User.changeset(%User{}, user_data))
    %{user: user}
  end

  def create_auth_provider(%{user: user}, attrs \\ %{}) do
    data =
      Map.merge(
        %{
          provider: :identity,
          subject_id: "UserAuthProviderSubjectId"
        },
        attrs
      )

    {:ok, %UserAuthProvider{} = user_auth_provider} =
      %UserAuthProvider{}
      |> UserAuthProvider.changeset(data)
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Repo.insert()

    %{user_auth_provider: user_auth_provider}
  end
end

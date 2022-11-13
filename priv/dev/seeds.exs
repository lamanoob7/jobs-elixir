# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Script generates random data values only when no old seed exist
# IDs are always new
#
# You can run force rebuild seed file
#
#     mix run priv/repo/seeds.exs --force
#

defmodule ElixirSkeleton.DatabaseSeeder do
  import Ecto.Query, only: [from: 2]

  alias ElixirSkeleton.Accounts
  alias ElixirSkeleton.Accounts.{User, UserAuthProvider, UserProfile, UserToken}
  alias ElixirSkeleton.Repo

  def insert_users(users) do
    users
    |> Enum.each(fn user_data ->
      {:ok, %{user: user}} = Accounts.register_user_and_profile(user_data)
      create_video_channels(user, Map.get(user_data, "video_channels"))
      user
    end)

    Repo.all(from u in User, preload: [:user_profile, :video_channels])
  end

  def clean() do
    Repo.delete_all(UserAuthProvider)
    Repo.delete_all(UserProfile)
    Repo.delete_all(UserToken)
    Repo.delete_all(User)
  end
end

defmodule ElixirSkeleton.DatabaseSeedGenerator do
  @users [
    %{
      email: "admin@admin.admin",
      password: "adminadminadmin",
      hashed_password: "$2b$12$U7qhMQJQ3iSH0z1tX51LSe7Vtr51OnsmC0QcrFKNzIA.fNYic06z.",
      role: :admin,
      confirmet_at: "2021-01-01 01:01:01",
      first_name: "first admin name",
      last_name: "last admin name",
      # change admin pictures
      picture: "video_categories/1000-600x500.jpg"
    },
    %{
      email: "user@user.user",
      password: "useruseruser",
      hashed_password: "$2b$12$AMO7GUJYd5GsQSvPgsAPeu.3I5Ye0N84HuhuiFbjztmepINBXBHVi",
      role: :user,
      confirmet_at: "2021-01-02 01:01:01",
      first_name: "first user name",
      last_name: "last user name",
      # change user pictures
      picture: "video_categories/500-600x500.jpg"
    }
  ]

  def get_users() do
    @users
    |> Enum.map(fn user_data ->
      user_data
      |> Map.put(:user_profile, get_user_profile(user_data))
      |> Map.put(:video_channels, get_video_channels(user_data))
    end)
  end

  defp get_user_profile(user_data) do
    %{
      first_name: Map.get(user_data, :first_name),
      last_name: Map.get(user_data, :last_name),
      picture: Map.get(user_data, :picture)
    }
  end
end

defmodule DataSeed do
  require Logger

  @filename "priv/dev/seeds.json"

  def seed_exist? do
    case File.open(@filename) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  def get_seed_data() do
    with {:ok, body} <- File.read(@filename),
         {:ok, json} <- Jason.decode(body) do
      {:ok, json}
    end
  end

  def remove_seed() do
    Logger.info("Force removing old seed")
    File.rm(@filename)
  end

  def generate_data do
    %{
      users: ElixirSkeleton.DatabaseSeedGenerator.get_users(),
      video_categories: ElixirSkeleton.DatabaseSeedGenerator.get_video_categories(),
      videos: ElixirSkeleton.DatabaseSeedGenerator.get_videos()
    }
  end

  def store_data(data) do
    File.mkdir_p(Path.dirname(@filename))
    File.chmod(Path.dirname(@filename), 0o777)
    {:ok, encoded_data} = Jason.encode(data)
    File.write(@filename, encoded_data)
    {:ok, encoded_data}
  end
end

if Mix.env() in [:dev] do
  if "--force" in System.argv() do
    DataSeed.remove_seed()
  end

  seed_data =
    if DataSeed.seed_exist?() do
      {:ok, decoded_data} = DataSeed.get_seed_data()
      decoded_data
    else
      {:ok, json_data} =
        DataSeed.generate_data()
        |> DataSeed.store_data()

      # because indexes after json decode are string not atoms
      {:ok, decoded_data} = Jason.decode(json_data)
      decoded_data
    end

  ElixirSkeleton.DatabaseSeeder.clean()
  users = ElixirSkeleton.DatabaseSeeder.insert_users(Map.get(seed_data, "users"))
end

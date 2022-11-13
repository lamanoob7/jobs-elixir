defmodule ElixirTemplate.Repo.Migrations.AddUserAuthProvidera do
  use Ecto.Migration

  def up do
    execute(
      "CREATE TYPE public.user_auth_provider_provider_enum AS ENUM ('apple', 'facebook', 'google', 'identity')"
    )

    create table(:users_auth_providers, primary_key: false) do
      add :provider, :"public.user_auth_provider_provider_enum", null: false, primary_key: true
      add :subject_id, :string, null: false, primary_key: true
      add :user_id, references(:users, on_delete: :nothing, type: :uuid), null: false
      add :data, :map, null: true

      timestamps()
    end
  end

  def down do
    drop table(:users_auth_providers)

    execute("DROP TYPE public.user_auth_provider_provider_enum")
  end
end

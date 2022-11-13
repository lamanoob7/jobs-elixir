defmodule ElixirTemplate.Repo.Migrations.AddUserProfile do
  use Ecto.Migration

  def up do
    create table(:users_profiles, primary_key: false) do
      add :user_id, references(:users, on_delete: :nothing, type: :uuid),
        null: false,
        primary_key: true

      add :first_name, :string, null: true
      add :last_name, :string, null: true
      add :picture, :string, null: true
      timestamps(inserted_at: false)
    end
  end

  def down do
    drop table(:users_profiles)
  end
end

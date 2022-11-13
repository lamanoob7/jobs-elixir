defmodule ElixirTemplate.Repo.Migrations.AddUserRole do
  use Ecto.Migration

  def up do
    execute("CREATE TYPE public.user_role_enum AS ENUM ('admin', 'user')")

    alter table(:users) do
      modify :hashed_password, :string, null: true
      add :role, :"public.user_role_enum", null: false, default: "user"
    end
  end

  def down do
    alter table(:users) do
      remove :role
      modify :hashed_password, :string, null: false
    end

    execute("DROP TYPE public.user_role_enum")
  end
end

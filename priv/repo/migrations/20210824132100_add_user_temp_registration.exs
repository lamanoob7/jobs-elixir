defmodule ElixirTemplate.Repo.Migrations.AddUserTempRegistration do
  use Ecto.Migration

  def change do
    create table(:users_temp_registration) do
      add :email, :string
      add :token, :binary, null: false
      timestamps(updated_at: false)
    end
  end
end

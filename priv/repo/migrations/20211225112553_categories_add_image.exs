defmodule Binshop.Repo.Migrations.CategoriesAddImage do
  use Ecto.Migration

  def change do
    alter table(:categories) do
      add :image, :string, null: true
    end
  end
end

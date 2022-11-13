defmodule Binshop.Schema do
  @moduledoc "Base schema with pre-configured preferences."

  import Ecto.Changeset, only: [get_change: 2, put_change: 3]

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      alias Binshop.Repo
      import Ecto.Query, only: [from: 2]

      @timestamps_opts [type: :utc_datetime]
      @primary_key {:id, Ecto.ShortUUID, autogenerate: true}
      @foreign_key_type Ecto.ShortUUID

      @doc "Slugifies the specified field."
      def slugify(changeset, key) when is_atom(key) do
        if str = get_change(changeset, key) do
          slug = unique_slug(str)
          put_change(changeset, :slug, slug)
        else
          changeset
        end
      end

      def unique_slug(str) do
        slug = Slug.slugify(str)
        query = from scheme in __MODULE__, where: ilike(scheme.slug, ^"#{slug}%")
        count = Repo.aggregate(query, :count, :id)

        if count > 0 do
          "#{slug}-#{count}"
        else
          slug
        end
      end
    end
  end
end

defmodule Binshop.Repo do
  use Ecto.Repo,
    otp_app: :binshop,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 10

  @doc "Cursor based pagination."
  def paginate_cursor(queryable, opts \\ [], repo_opts \\ []) do
    defaults = [limit: 30, maximum_limit: 100, include_total_count: true]
    opts = Keyword.merge(defaults, opts)
    Paginator.paginate(queryable, opts, __MODULE__, repo_opts)
  end
end

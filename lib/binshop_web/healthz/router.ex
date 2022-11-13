defmodule BinshopWeb.Healthz.Router do
  use BinshopWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BinshopWeb.Healthz do
    pipe_through [:api]

    get "/liveness", StatusController, :liveness
    get "/readiness", StatusController, :readiness
  end

  # Enables LiveDashboard
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through [:fetch_session, :protect_from_forgery]

    live_dashboard "/dashboard",
      metrics: BinshopWeb.Telemetry,
      ecto_repos: [Binshop.Repo]
  end
end

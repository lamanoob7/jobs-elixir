defmodule Binshop.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias BinshopWeb.Endpoint

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Binshop.Repo,
      # Start the Telemetry supervisor
      BinshopWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Binshop.PubSub},
      # Start the Endpoint (http/https)
      Endpoint,
      # Start the Healthz Endpoint (http)
      BinshopWeb.HealthzEndpoint,
      # setup for clustering
      {Cluster.Supervisor,
       [
         Application.get_env(:libcluster, :topologies),
         [name: Binshop.ClusterSupervisor]
       ]},
      Binshop.Baskets.Server
      # Start a worker by calling: Binshop.Worker.start_link(arg)
      # {Binshop.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Binshop.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end

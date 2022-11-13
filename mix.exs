defmodule Binshop.MixProject do
  use Mix.Project

  def project do
    [
      app: :binshop,
      version: "0.1.0",
      elixir: "~> 1.12.2",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "test.all": :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "test.all.cover": :test
      ],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        check_plt: true,
        plt_add_apps: [:mix, :ex_unit]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Binshop.Application, []},
      extra_applications: [:logger, :runtime_tools, :ueberauth_google, :ueberauth_identity]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 2.0"},
      {:phoenix, "~> 1.6"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.16.4", override: true},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:credo, "~> 1.5.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.25.0", only: [:dev, :test], runtime: false},
      {:set_locale, "~> 0.2.9"},
      {:sobelow, "~> 0.11", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14.0", only: [:dev, :test], runtime: false},
      {:paginator, github: "duffelhq/paginator"},
      {:shortuuid, "~> 2.1"},
      {:ecto_shortuuid, "~> 0.1"},
      {:uuid, "~> 1.1"},
      {:scrivener_ecto, "~> 2.7"},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_google, "~> 0.10"},
      {:surface, "~> 0.6"},
      {:ueberauth_identity, "~> 0.3"},
      {:libcluster, "~> 3.3"},
      {:bamboo, "~> 2.2.0"},
      {:ex_json_schema, "~> 0.8.1"},
      {:slugify, "~> 1.3"},
      {:accessible, "~> 0.3.0"},
      {:ex_aws, "~> 2.2"},
      {:ex_aws_s3, "~> 2.1"},
      {:tzdata, "~> 1.0.1"},
      {:typed_struct, "~> 0.3.0"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "test.all": [
        "hex.audit",
        "format --check-formatted --dry-run",
        "compile --warnings-as-errors --force",
        "credo --strict",
        "sobelow --config",
        "docs",
        "test --cover",
        "dialyzer --format short"
      ],
      "test.all.cover": ["test.all", "coveralls.html"],
      "assets.deploy": [
        "esbuild default --minify",
        "cmd --cd assets npm run deploy:css",
        "cmd --cd assets npm run deploy:gulp",
        "phx.digest"
      ]
    ]
  end
end

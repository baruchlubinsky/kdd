defmodule Kdd.MixProject do
  use Mix.Project

  def project do
    [
      app: :kdd,
      version: "0.2.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Kdd.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:phoenix, "~> 1.7.21"},
      {:phoenix_ecto, "~> 4.6.5"},
      {:ecto_sql, "~> 3.13.2"},
      {:postgrex, "~> 0.20.0"},
      {:phoenix_html, "~> 4.2.1"},
      {:phoenix_live_reload, "~> 1.6.0", only: :dev},
      {:phoenix_live_view, "~> 1.0.17"},
      {:floki, "~> 0.38.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.7"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1.8", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.19.3"},
      {:finch, "~> 0.19.0"},
      {:telemetry_metrics, "~> 1.1.0"},
      {:telemetry_poller, "~> 1.2.0"},
      {:gettext, "~> 0.26.2"},
      {:jason, "~> 1.4.4"},
      {:plug_cowboy, "~> 2.7.4"},
      {:kdd_notion_ex, git: "https://github.com/baruchlubinsky/kdd_notion_ex.git", tag: "0.1.8"}
      #{:kdd_notion_ex, path: "../kdd_notion_ex"}
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
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end

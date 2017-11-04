defmodule Plunger.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plunger,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Plunger.Application, []},
      extra_applications: [:coherence, :logger, :runtime_tools,
      :comeonin, :bcrypt_elixir]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:comeonin, "~> 3.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:phoenix_mtm, "~> 0.5.1"},
      {:hound, "~> 1.0"},
      {:navigation_history, "~> 0.0"},
      #{:ueberauth, "~> 0.4"},
      #{:ueberauth_identity, "~> 0.2"},
      #{:ueberauth_google, "~> 0.2"},
      #{:ueberauth_facebook, "~> 0.7"},
      #{:ueberauth_github, "~> 0.4"},
      #{:guardian_db, "~> 0.8.0"},
      #{:guardian, "~> 0.14"},
      {:arc, "~> 0.8.0"},
      {:arc_ecto, "~> 0.7.0"},
      {:coherence, "~> 0.5"},
      {:coherence_assent, "~> 0.2.0"},
      {:earmark, "~> 1.1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end

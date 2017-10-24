# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :plunger,
  ecto_repos: [Plunger.Repo]

# Configures the endpoint
config :plunger, PlungerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "s65X9mklxd2MCk+1TB2Ajk3LhFuNYv3xyohvcSbEdc6n/W7/II1CuZ7kuiXlMSGl",
  render_errors: [view: PlungerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Plunger.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


config :guardian, Guardian,
  issuer: "Plunger.#{Mix.env}",
  ttl: {30, :days},
  verify_issuer: true,
  serializer: PlungerWeb.GuardianSerializer,
  secret_key: to_string(Mix.env),
  hooks: GuardianDb,
  permissions: %{
  default: [
      :read_profile,
      :write_profile,
      :read_token,
      :revoke_token,
    ],
  }

config :guardian_db, GuardianDb,
       repo: Plunger.Repo

config :hound, browser: "chrome"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

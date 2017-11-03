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

config :plunger, PlungerWeb.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "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"

config :hound, browser: "chrome"

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Plunger.Accounts.User,
  repo: Plunger.Repo,
  module: Plunger,
  web_module: PlungerWeb,
  router: PlungerWeb.Router,
  messages_backend: PlungerWeb.Coherence.Messages,
  logged_out_url: "/",
  email_from_name: "Plunger",
  email_from_email: "test@localhost.com",
  opts: [:authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :confirmable, :registerable]

config :coherence, PlungerWeb.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "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"
# %% End Coherence Configuration %%

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

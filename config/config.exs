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
  root: Path.expand("..", __DIR__),
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

config :coherence_assent, :providers,
       [
         github: [
           client_id: "6519429fac7ec21d4d3a",
           client_secret: "7510f495ffcda1a76241c8464a7e09cdf8c479a3",
           strategy: CoherenceAssent.Strategy.Github
        ],

        google: [
          client_id: "42412947581-qbqfmh0ouo3ajtdl952knnun99n4cfud.apps.googleusercontent.com",
          client_secret: "QJlFSRe4G2X5utIwxdXJQSOg",
          strategy: CoherenceAssent.Strategy.Google
       ],

       facebook: [
         client_id: "540031066343381",
         client_secret: "9b84d64c9cc4c99afdc02c423a67e964",
         strategy: CoherenceAssent.Strategy.Facebook
      ]
      ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

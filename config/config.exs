# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :funbox, github_client: Funbox.GithubClient.Impl
config :funbox, content_parser: Funbox.ContentParser.Impl
config :funbox, content_transformer: Funbox.ContentTransformer.Impl

config :funbox, Oban,
  repo: Funbox.Repo,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 24 * 60 * 60},
    {Oban.Plugins.Cron, crontab: [{"@daily", Funbox.ContentCrawlerWorker}]}
  ],
  queues: [default: 10, crawler: 1]

config :funbox,
  ecto_repos: [Funbox.Repo]

# Configures the endpoint
config :funbox, FunboxWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: FunboxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Funbox.PubSub,
  live_view: [signing_salt: "5XgtQaJb"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :funbox, Funbox.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tentacat, :deserialization_options, keys: :atoms

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :funbox, Oban, testing: :inline
config :funbox, github_client: Funbox.GithubClient.Mock
config :funbox, content_parser: Funbox.ContentParser.Mock
config :funbox, content_transformer: Funbox.ContentTransformer.Mock

config :funbox, Funbox.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "funbox_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :funbox, FunboxWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "jAUxttP164V5g3xl76zn6Fs3HO5Px+rjjZCI6B088ISTmqmPPEZON9hYiiygwZqr",
  server: false

# In test we don't send emails.
config :funbox, Funbox.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

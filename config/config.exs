# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :users,
  ecto_repos: [Users.Repo]

# Configures the endpoint
config :users, UsersWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "v0bdG5STe0UC1x+za/FcaFVdyNGfcJ+KAdlyqC0TLuo1M0kKrvwLdEHoEXA3fBxH",
  render_errors: [view: UsersWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Users.PubSub,
  live_view: [signing_salt: "1Y0HN9ml"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian
config :users, Users.Guardian,
       issuer: "users",
       secret_key: "ip2pBLP5o9vKsTYxJoA08huGXa2sQmCV0796hWK8wPNupNFtCneW7rKFNhaKwpKJ"     # Secret key. You can use `mix guardian.gen.secret` to get one

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

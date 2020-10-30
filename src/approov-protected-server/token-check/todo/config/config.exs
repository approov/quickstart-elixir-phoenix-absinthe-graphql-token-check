# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :todo, TodoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "udep/Hn8goqZbTLF3Wtn1eBKtSRb0Umhebl6gxrE085tSNZMNvyJ4IDtE3eERxMv",
  render_errors: [view: TodoWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Todo.PubSub,
  live_view: [signing_salt: "ybFSxyfy"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

import_config "releases.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

encryption_secret =
  System.get_env("ENCRYPTION_SECRET") ||
    raise """
    environment variable ENCRYPTION_SECRET is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :todo, TodoWeb.Endpoint,
  secret_key_base: secret_key_base,
  encryption_secret: encryption_secret

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :todo, TodoWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.

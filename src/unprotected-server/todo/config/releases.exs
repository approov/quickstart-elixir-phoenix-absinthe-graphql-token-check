import Config

http_internal_port = System.get_env("HTTP_INTERNAL_PORT") || raise "Missing HTTP_INTERNAL_PORT env var"
url_public_scheme = System.get_env("URL_PUBLIC_SCHEME") || "https"
url_public_host = System.get_env("URL_PUBLIC_HOST") || raise "Missing URL_PUBLIC_HOST env var"
url_public_port = System.get_env("URL_PUBLIC_PORT") || 443
url_public = "#{url_public_scheme}://#{url_public_host}"

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
config :todo, TodoWeb.Endpoint,
  server: true,
  http: [
    # Like the one used inside a docker container and/or behind a proxy
    port: http_internal_port,
    transport_options: [
      socket_opts: [:inet6],
    ],
  ],
  url: [
    scheme: url_public_scheme,
    host: url_public_host,
    port: url_public_port
  ],
  check_origin: [url_public]

#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.

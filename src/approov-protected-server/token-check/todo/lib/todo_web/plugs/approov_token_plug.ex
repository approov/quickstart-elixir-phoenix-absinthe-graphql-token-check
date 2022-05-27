defmodule TodoWeb.ApproovTokenPlug do
  require Logger

  ##############################################################################
  # Adhere to the Phoenix Module Plugs specification by implementing:
  #   * init/1
  #   * call/2
  #
  # @link https://hexdocs.pm/phoenix/plug.html#module-plugs
  ##############################################################################

  # Don't use this function to init the Plug with the Approov secret, because
  # this is only evaluated at compile time, and we don't want the to have
  # secrets inside a release. Secrets must always be retrieved from the
  # environment where the release is running.
  def init(opts), do: opts

  # Allows to use the GraphqiQL web interface without requiring the Approov
  # token that is required for all requests in production.
  if Mix.env() in [:dev, :test] do
    # Allows to load the web interface for GraphiQL at `example.com/graphiql`
    # without checking for the Approov token.
    def call(%{method: "GET", request_path: "/graphiql"} = conn, _options), do: conn

    # The GraphqiQL web interface does some introspection queries to help with
    # validation and auto-completion, therefore we must allow them without
    # the need for an Approov token.
    def call(%{method: "POST", request_path: "/graphiql", params: %{"query" => "\n  query IntrospectionQuery" <> _query}} = conn, _options), do: conn
  end

  def call(conn, _opts) do
    case ApproovToken.verify_token(conn) do
      {:ok, approov_token_claims} ->
        conn
        |> Plug.Conn.put_private(:approov_token_claims, approov_token_claims)

      {:error, _reason} ->
        conn
        |> _halt_connection()
    end
  end

  # When the Approov token validation fails we return a `401` with an empty body,
  # because we don't want to give clues to an attacker about the reason the
  # request failed, and you can go even further by returning a `400`. Feel free
  # to modify as you see fits best your use case.
  defp _halt_connection(conn) do
    conn
    |> Plug.Conn.put_status(401)
    |> Phoenix.Controller.json(%{})
    |> Plug.Conn.halt()
  end
end

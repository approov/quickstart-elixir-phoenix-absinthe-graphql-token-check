defmodule TodoWeb.ApproovTokenBindingPlug do

  ##############################################################################
  # Adhere to the Phoenix Module Plugs specification by implementing:
  #   * init/1
  #   * call/2
  #
  # @link https://hexdocs.pm/phoenix/plug.html#module-plugs
  ##############################################################################

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
    case ApproovToken.verify_token_binding(conn) do
      :ok ->
        conn

      {:error, _reason} ->
        conn
        |> _halt_connection()
    end
  end

  defp _halt_connection(conn) do
    conn
    |> Plug.Conn.put_status(401)
    |> Phoenix.Controller.json(%{})
    |> Plug.Conn.halt()
  end
end

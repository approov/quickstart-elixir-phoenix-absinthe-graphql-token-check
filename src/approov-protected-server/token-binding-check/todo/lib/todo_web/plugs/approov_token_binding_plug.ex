defmodule TodoWeb.ApproovTokenBindingPlug do
  require Logger

  ##############################################################################
  # Adhere to the Phoenix Module Plugs specification by implementing:
  #   * init/1
  #   * call/2
  #
  # @link https://hexdocs.pm/phoenix/plug.html#module-plugs
  ##############################################################################

  def init(options), do: options

  # Allows to load the web interface for GraphiQL at `example.com/graphiql`
  # without checking for the Approov token.
  def call(%{method: "GET", request_path: "/graphiql", query_string: ""} = conn, _options) do
    conn
  end

  def call(conn, _opts) do
    with :ok <- ApproovToken.verify_token_binding(conn) do
      conn
    else
      {:error, reason} ->
        # Logs are set to :debug level, aka for development. Customize it for your needs.
        _log_error(reason)

        conn
        |> _halt_connection()
    end
  end

  defp _log_error(reason) when is_atom(reason), do: Logger.warn(Atom.to_string(reason))
  defp _log_error(reason), do: Logger.warn(reason)

  defp _halt_connection(conn) do
    conn
    |> Plug.Conn.put_status(401)
    |> Phoenix.Controller.json(%{})
    |> Plug.Conn.halt()
  end
end

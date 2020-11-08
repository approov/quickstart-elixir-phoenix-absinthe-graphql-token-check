defmodule TodoWeb.ApproovTokenPlug do
  require Logger

  ##############################################################################
  # Adhere to the Phoenix Module Plugs specification by implementing:
  #   * init/1
  #   * call/2
  #
  # @link https://hexdocs.pm/phoenix/plug.html#module-plugs
  ##############################################################################

  def init(options) do
    jwk = %{
      "kty" => "oct",
      "k" =>  Application.fetch_env!(:todo, ApproovToken)[:secret_key]
    }

    [{:approov_jwk, jwk} | options]
  end

  # Allows to load the web interface for GraphiQL at `example.com/graphiql`
  # without checking for the Approov token.
  def call(%{method: "GET", request_path: "/graphiql", query_string: ""} = conn, _options) do
    conn
  end

  def call(conn, [{:approov_jwk, approov_jwk}]) do
    with {:ok, approov_token_claims} <- ApproovToken.verify(conn, approov_jwk) do
      conn
      |> Plug.Conn.put_private(:todo_approov_token_claims, approov_token_claims)
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

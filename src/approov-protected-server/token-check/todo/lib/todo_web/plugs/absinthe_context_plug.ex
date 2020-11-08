defmodule TodoWeb.AbsintheContextPlug do
  @behaviour Plug

  require Logger

  def init(opts), do: opts

  # Allows to load the web interface for GraphiQL at `example.com/graphiql`
  # without checking for the Authorization token.
  def call(%{method: "GET", request_path: "/graphiql", query_string: ""} = conn, _options) do
    conn
  end

  def call(conn, _) do
    conn
    |> _authorize()
  end

  defp _authorize(%Plug.Conn{} = conn) do
    with {:ok, token} <- _get_authorization_header(conn),
         {:ok, current_user}  <- Todos.User.authorize(token: token) do
      conn
      |> Absinthe.Plug.put_options(context: %{current_user: current_user})

    else
      {:error, reason} ->
        _log_error(reason)

        conn
        # |>_halt_connection()
        |> Absinthe.Plug.put_options(context: %{})
    end
  end

  defp _get_authorization_header(conn) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      [] ->
        _get_authorization_params(conn.params)

      [token] ->
        {:ok, token}

      error ->
        _log_error(error)
    end
  end

  defp _get_authorization_params(%{"Authorization" => token}), do: {:ok, token}
  defp _get_authorization_params(_params), do: {:error, :missing_authorizarion_token}

  defp _log_error(reason) when is_atom(reason), do: Logger.warn(Atom.to_string(reason))
  defp _log_error(reason), do: Logger.warn(reason)

  # defp _halt_connection(conn) do
  #   conn
  #   # |> Absinthe.Plug.put_options(context: %{})

  #   |> Plug.Conn.put_status(401)
  #   |> Phoenix.Controller.json(%{})
  #   |> Plug.Conn.halt()
  # end
end

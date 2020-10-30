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
    with ["Bearer " <> token] <- Plug.Conn.get_req_header(conn, "authorization"),
         {:ok, current_user}  <- Todos.User.authorize(token: token) do
      conn
      |> Absinthe.Plug.put_options(context: %{current_user: current_user})
    else
      [] ->
        Logger.error("Missing the Authorization header")

        conn
        |>_halt_connection()

      {:error, reason} ->
        Logger.error(reason)

        conn
        |>_halt_connection()
    end
  end

  defp _halt_connection(conn) do
    conn
    |> Absinthe.Plug.put_options(context: %{})

    # |> Plug.Conn.put_status(401)
    # |> Phoenix.Controller.json(%{})
    # |> Plug.Conn.halt()
  end
end

defmodule TodoWeb.AuthController do

  use TodoWeb, :controller

  def signup(conn, params) do
    case Todos.User.create(params) do
      {:ok, user} ->
        json(conn, %{id: user.uid})

      {:error, _reason} ->
        _send_error_response(conn, "Failed to create user")
    end
  end

  def login(conn, params) do
    case Todos.User.authenticate(params) do
      {:ok, user} ->
        json(conn, %{token: user.token})

      {:error, _reason} ->
        _send_error_response(conn,"Failed to authenticate user")
    end
  end

  defp _send_error_response(conn, message) do
    conn
    |> Plug.Conn.put_status(401)
    |> json(%{error: message})
  end
end

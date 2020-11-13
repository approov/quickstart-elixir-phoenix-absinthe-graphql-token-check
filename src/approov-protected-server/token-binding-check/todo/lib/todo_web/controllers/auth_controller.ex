defmodule TodoWeb.AuthController do

  use TodoWeb, :controller

  def signup(conn, params) do
    case Todos.User.create(params) do
      {:ok, user} ->
        json(conn, %{id: user.uid})

      {:error, _reason} ->
        json(conn, %{error: "Failed to create user"})
    end
  end

  def login(conn, params) do
    case Todos.User.authenticate(params) do
      {:ok, user} ->
        json(conn, %{token: user.token})

      {:error, _reason} ->
        json(conn, %{error: "Failed to authenticate user"})
    end
  end
end

defmodule TodoWeb.TodoController do

  use TodoWeb, :controller

  def show(conn, _params) do
    json(conn, %{message: "Tasks Todo!"})
  end
end

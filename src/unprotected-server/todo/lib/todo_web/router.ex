defmodule TodoWeb.Router do
  use TodoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug TodoWeb.AbsintheContextPlug
  end

  scope "/graphiql" do
    pipe_through :api
    pipe_through :graphql

    # The `/graphiql` endpoint exposes too much to attackers, thus in my opinion
    # should not be available in production.
    if Mix.env() in [:dev, :test] do
      forward "/", Absinthe.Plug.GraphiQL,
        schema: TodoWeb.Schema,
        socket: TodoWeb.UserSocket
    end
  end

  scope "/" do
    pipe_through :api
    pipe_through :graphql

    forward "/", Absinthe.Plug,
      schema: TodoWeb.Schema
  end

end

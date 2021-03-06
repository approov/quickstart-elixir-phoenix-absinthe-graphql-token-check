defmodule TodoWeb.Router do
  use TodoWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :live_view_dashboard_auth do
    plug TodoWeb.LiveViewDashboardAuthPlug
  end

  pipeline :approov_token do
    # Ideally you will not want to add any other Plug before the Approov Token
    # check to protect your server from wasting resources in processing requests
    # not having a valid Approov token. This increases availability for your
    # users during peak time or in the event of a DoS attack(We all know the
    # BEAM design allows to cope very well with this scenarios, but best to play
    # in the safe side).
    plug TodoWeb.ApproovTokenPlug
  end

  pipeline :approov_token_binding do
    plug TodoWeb.ApproovTokenBindingPlug
  end

  pipeline :graphql do
    plug TodoWeb.AbsintheContextPlug
  end

  scope "/" do
    pipe_through :api
    pipe_through :approov_token

    post "/auth/signup", TodoWeb.AuthController, :signup
    post "/auth/login", TodoWeb.AuthController, :login
  end

  scope "/dashboard" do
    pipe_through [:browser, :live_view_dashboard_auth]
    live_dashboard "/"
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
    pipe_through :approov_token
    pipe_through :approov_token_binding
    pipe_through :graphql

    forward "/", Absinthe.Plug,
      schema: TodoWeb.Schema
  end

end

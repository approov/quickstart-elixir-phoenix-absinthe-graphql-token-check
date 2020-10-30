defmodule Todo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    :ets.new(:todos, [:set, :protected, :named_table, :public])

    children = [
      # Start the Telemetry supervisor
      TodoWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Todo.PubSub},
      # Start the Endpoint (http/https)
      TodoWeb.Endpoint,
      # Start a worker by calling: Todo.Worker.start_link(arg)
      # {Todo.Worker, arg}
      {Absinthe.Subscription, TodoWeb.Endpoint}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Todo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TodoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

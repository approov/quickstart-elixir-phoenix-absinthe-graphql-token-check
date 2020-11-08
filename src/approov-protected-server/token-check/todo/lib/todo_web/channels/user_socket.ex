defmodule TodoWeb.UserSocket do
  use Phoenix.Socket

  use Absinthe.Phoenix.Socket, schema: TodoWeb.Schema

  require Logger

  defp _approov_jwk() do
    %{
      "kty" => "oct",
      "k" =>  Application.fetch_env!(:todo, ApproovToken)[:secret_key]
    }
  end

  @impl true
  def connect(params, socket, _connect_info) do
    socket
    |> _authorize(params)
  end

  defp _authorize(socket, params) do
    # Add your user authentication logic here as you see fit. For example:
    with {:ok, _approov_token_claims} <- ApproovToken.verify(params, _approov_jwk()),
         {:ok, current_user} <- Todos.User.authorize(params: params) do
      socket = Absinthe.Phoenix.Socket.put_options(socket, context: %{current_user: current_user})
      {:ok, socket}
    else
      {:error, reason} ->
        # Logs are set to :debug level, aka for development. Customize it for your needs.
        _log_error(reason)
        :error
    end
  end

  defp _log_error(reason) when is_atom(reason), do: Logger.error(Atom.to_string(reason))
  defp _log_error(reason), do: Logger.error(reason)

  @impl true
  def id(_socket), do: nil
end

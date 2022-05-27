defmodule TodoWeb.UserSocket do
  use Phoenix.Socket

  use Absinthe.Phoenix.Socket, schema: TodoWeb.Schema

  require Logger

  @impl true
  def connect(params, socket, connect_info) do
    Logger.info(%{socket_connect_params: params})
    Logger.info(%{socket_connect_info: connect_info})

    socket
    |> _authorize(params, connect_info)
  end

  @impl true
  def id(_socket), do: nil

  defp _authorize(socket, params, connect_info) do
    # We need to merge them because the requests from the GraphiQL web interface doesn't populate the `connect_info` with the Approov token.
    headers = Map.merge(params, connect_info)

    # Always perform the Approov token check before the User Authentication.
    with {:ok, _approov_token_claims} <- ApproovToken.verify_token(headers),
         {:ok, current_user} <- Todos.User.authorize(params: params) do

      socket = Absinthe.Phoenix.Socket.put_options(socket, context: %{current_user: current_user})

      {:ok, socket}
    else
      {:error, _reason} ->
        :error
    end
  end

end

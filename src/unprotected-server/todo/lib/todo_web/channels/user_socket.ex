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

  defp _authorize(socket, params, _connect_info) do
    # Add your user authentication logic here as you see fit. For example:
    with {:ok, current_user} <- Todos.User.authorize(params: params) do

      socket = Absinthe.Phoenix.Socket.put_options(socket, context: %{current_user: current_user})

      {:ok, socket}
    else
      {:error, reason} ->
        _log_error(reason)
        :error
    end
  end

  defp _log_error(reason) when is_atom(reason), do: Logger.warn(Atom.to_string(reason))
  defp _log_error(reason), do: Logger.warn(reason)

end

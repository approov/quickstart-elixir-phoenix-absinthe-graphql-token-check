defmodule Todos.User do

  def authorize(token: token) when is_binary(token) do
    # Add your logic here to authorize the user in the token as you see fit.
    current_user = %{id: 12345, name: "John Doe"}
    {:ok, current_user}
  end

  def authorize(token: _token), do: {:error, :invalid_token}

  def authorize(params: %{"Authorization" => "Bearer " <> token}), do: authorize(token: token)
  def authorize(params: _params), do: {:error, :cannot_authorize}

  def authorized(_action, current_user) do
    # Add your logic here as you see fit.
    {:ok, current_user}
  end

  def can_do_action?(_payload) do
    # Add your logic here as you see fit.
    true
  end

end

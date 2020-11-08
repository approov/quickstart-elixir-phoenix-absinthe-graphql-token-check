defmodule Utils do

  @salt Application.get_env(:todo, TodoWeb.Endpoint)[:secret_key_base]

  def build_user_uid(username: username) do
    :crypto.hash(:sha256, "#{username}#{@salt}") |> Base.encode16
  end

  def sha256(text) do
    :crypto.hash(:sha256, "#{@salt}#{text}") |> Base.encode16
  end

end

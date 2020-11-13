defmodule Utils do

  def build_user_uid(username: username) do
    :crypto.hash(:sha256, "#{username}#{secret_key_base()}") |> Base.encode16
  end

  def sha256(text) do
    :crypto.hash(:sha256, "#{secret_key_base()}#{text}") |> Base.encode16
  end

  def secret_key_base() do
    fetch_from_env!(:todo, TodoWeb.Endpoint, :secret_key_base, 64, :string)
  end

  def encryption_secret() do
    fetch_from_env!(:todo, TodoWeb.Endpoint, :encryption_secret, 64, :string)
  end

  def fetch_from_env!(app, module, key, min_length, :string) do
    case Application.fetch_env!(app, module)[key] do
      value when is_binary(value) and byte_size(value) >= min_length ->
        value

      _ ->
        raise %ArgumentError{message: "Environment key #{key} for #{module} needs to be a string and have at least #{min_length} of length."}
    end
  end

end

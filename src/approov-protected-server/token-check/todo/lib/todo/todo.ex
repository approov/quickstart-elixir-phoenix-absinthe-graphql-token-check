defmodule Todos.Todo do

  def insert(%{id: key} = data, table) when is_binary(key) do
    key
    |> String.to_integer()
    |> _insert(data, table)
  end

  def insert(%{id: key} = data, table) do
    _insert(key, data, table)
  end

  defp _insert(key, data, table) when is_integer(key) do
    case :ets.insert_new(table, {key, data}) do
      true ->

        Absinthe.Subscription.publish(
          TodoWeb.Endpoint,
          data,
          todo_added: :todos
        )

        {:ok, data}

      _ ->

        {:error, :unknown}
    end
  end

  def update(data, table) do
    case lookup(data.id, table) do
      :not_found ->
        :not_found

      record ->

        record = Map.merge(record, data)
        _update(record.id, record, table)
        record
    end
  end

  defp _update(key, record, table) when is_binary(key) do
    key
    |> String.to_integer()
    |> _update(record, table)
  end

  defp _update(key, record, table) when is_integer(key) do
    :ets.insert(table, {key, record})
  end

  def lookup(key, table) when is_binary(key) do
    String.to_integer(key)
    |> lookup(table)
  end

  def lookup(key, table) do
    case :ets.lookup(table, key) do
      [{_key, record}] ->
        record

      _ ->
        :not_found
    end
  end

  def all(table) do
    :ets.tab2list(table)
    |> Enum.map(fn {_id, todo} -> todo end)
  end

end

defmodule Todos.OnlineUser do

  require Logger

  @table :online_users

  def all_users() do
    {
      :ok,
      Todos.Repo.all!(@table)
    }
  end

  def all_users!() do
    {:ok, all_users} = all_users()
    all_users
  end

  def add_user(%{name: name, uid: uid}) do
    online_user = %{
      uid: uid,
      name: String.split(name, "@") |> Enum.at(0),
      last_seen: NaiveDateTime.utc_now()
    }

    case Todos.Repo.insert_or_update(online_user, @table) do
      {:ok, record} ->
        _publish_to_subscription(record)

        {:ok, record}

      {:error, :insert_or_update_failed} ->
        Logger.debug("Unable to insert or update the online user.")
        {:error, :insert_or_update_failed}
    end
  end

  def update_last_seen(%{uid: uid}) do
    online_user = %{
      uid: uid,
      last_seen: NaiveDateTime.utc_now()
    }

    case Todos.Repo.update(online_user, @table) do
      {:ok, record} ->
        _publish_to_subscription(record)

        {:ok, record}

      {:error, :record_not_found} ->
        Logger.debug("The online user was not found.")
        {:error, :record_not_found}
    end
  end

  defp _publish_to_subscription(record) do
    record = Map.put(record, :last_seen, Calendar.strftime(record.last_seen, "%c"))

    Absinthe.Subscription.publish(
      TodoWeb.Endpoint,
      record,
      fetch_online_users: "online_users"
    )
  end
end

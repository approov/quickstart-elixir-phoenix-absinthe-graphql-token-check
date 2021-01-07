defmodule TodoWeb.LiveViewDashboardAuthPlug do

  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, credentials} <- _extract_credentials(conn),
         {:ok, users} <- _extract_users(credentials),
         {:ok, passwords} <- _extract_passwords(credentials),
         :ok <- _authenticate_live_view_user(users.live_view_user, passwords.live_view_password),
         {:ok, user} <- Todos.User.authenticate(%{"username" => users.app_user, "password" => passwords.app_password})
    do
      Plug.Conn.assign(conn, :current_user, user)
    else
      {:error, _reason} = error ->
        Logger.warn(%{live_view_dashboard: error})

        conn
        |> Plug.BasicAuth.request_basic_auth()
        |> Plug.Conn.halt()
    end
  end

  defp _extract_credentials(conn) do
    case Plug.BasicAuth.parse_basic_auth(conn) do
      {user, password}
        when is_binary(user)
        and byte_size(user) >= 11
        and is_binary(password)
        and byte_size(password) >= 18 ->
          {
            :ok,
            %{
              users: user,
              passwords: password
            }
          }

      _ ->
        {:error, :failed_to_extract_credentials}
    end
  end

  defp _extract_users(%{users: users} = _credentials) do
    case  String.split(users, "+++") do
      [live_view_user, app_user] ->
        {
          :ok,
          %{
            live_view_user: live_view_user,
            app_user: app_user,
          }
        }

      _ ->
        {:error, :failed_to_extract_users}
    end
  end

  defp _extract_passwords(%{passwords: passwords} = _credentials) do
    case  String.split(passwords, "+++") do
      [live_view_password, app_password] ->
        {
          :ok,
          %{
            live_view_password: live_view_password,
            app_password: app_password,
          }
        }

      _ ->
        {:error, :failed_to_extract_passwords}
    end
  end

  defp _authenticate_live_view_user(username, password)
    when is_binary(username)
    and byte_size(username) >= 8
    and is_binary(password)
    and byte_size(password) >= 8
  do
    with :ok <- _validate_live_view_user(username),
         :ok <- _validate_live_view_password(password)
    do
      :ok
    else
      error ->
        error
    end
  end

  defp _validate_live_view_user(username) do
    live_view_username = Utils.fetch_from_env!(:todo, TodoWeb.Endpoint, :live_view_dashboard_user, 8, :string)

    case live_view_username === username do
      true ->
        :ok

      false ->
        {:error, :failed_to_validate_live_view_user}
    end
  end

  defp _validate_live_view_password(password) do
    live_view_password = Utils.fetch_from_env!(:todo, TodoWeb.Endpoint, :live_view_dashboard_password, 8, :string)

    case Bcrypt.verify_pass(password, live_view_password) do
      true ->
        :ok

      false ->
        {:error, :failed_to_validate_live_view_password}
    end
  end

end

defmodule Todos.Context do

  require Logger

  @whoops "Whoops, Something went wrong!"

  def all_todos(%{current_user: current_user} = _context) do
    case Todos.User.authorized(:all_todos, current_user) do
      {:ok, _user} ->

        {
          :ok,
          Todos.Repo.all!(:todos)
          |> Enum.filter(fn todo -> todo.user_uid === current_user.uid end)
        }

      {:error, reason} ->
        Logger.warn(Atom.to_string(reason))
        {:error, @whoops}
    end
  end

  def all_todos(_context) do
    _handle_missing_user_for(:all_todos)
  end

  def active_todos(%{current_user: current_user} = _context) do
    case Todos.User.authorized(:active_todos, current_user) do
      {:ok, _user} ->

        {
          :ok,
          Todos.Repo.all!(:todos)
          |> Enum.filter(fn todo -> todo.user_uid === current_user.uid end)
          |> Enum.filter(fn todo -> todo.is_completed === false end)
        }

      {:error, reason} ->
        Logger.warn(Atom.to_string(reason))
        {:error, @whoops}
    end
  end

  def active_todos(_context) do
    _handle_missing_user_for(:active_todos)
  end

  def completed_todos(%{current_user: current_user} = _context) do
    case Todos.User.authorized(:completed_todos, current_user) do
      {:ok, _user} ->

        {
          :ok,
          Todos.Repo.all!(:todos)
          |> Enum.filter(fn todo -> todo.user_uid === current_user.uid end)
          |> Enum.filter(fn todo -> todo.is_completed === true end)
        }

      {:error, reason} ->
        Logger.warn(Atom.to_string(reason))
        {:error, @whoops}
    end
  end

  def completed_todos(_context) do
    _handle_missing_user_for(:completed_todos)
  end

  def create_todo(%{} = args, %{current_user: current_user} = _context) do
    case Todos.User.authorized(:create_todo, current_user) do
      {:ok, current_user} ->
        todo_id = System.unique_integer([:positive])

        todo = %{
          id: todo_id,
          uid: _build_todo_unique_id(todo_id, current_user),
          user_uid: current_user.uid,
          title: args.title,
          is_public: args.is_public,
          is_completed: false,
          created_at: NaiveDateTime.utc_now() |> NaiveDateTime.to_string()
        }

        Todos.Repo.insert(todo, :todos)

      {:error, reason} ->
        Logger.warn(Atom.to_string(reason))
        {:error, @whoops}
    end
  end

  def create_todo(_args, _context) do
    _handle_missing_user_for(:create_todo)
  end

  def toggle_todo(args, %{current_user: current_user} = _context) do
    todo = %{
      id: args.id,
      uid: _build_todo_unique_id(args.id, current_user),
      is_completed: args.is_completed
    }

    with  {:ok, _current_user} <- Todos.User.authorized(:create_todo, current_user),
          {:ok, todo} <- Todos.Repo.update(todo, :todos)
      do
        {:ok, todo}
      else
        {:error, reason} ->
          Logger.warn(Atom.to_string(reason))
          {:error, @whoops}
    end
  end

  def toggle_todo(_args, _context) do
    _handle_missing_user_for(:toggle_todo)
  end

  def delete_todo(args, %{current_user: current_user} = _context) do
    todo_uid = _build_todo_unique_id(args.id, current_user)

    with  {:ok, _current_user} <- Todos.User.authorized(:create_todo, current_user),
          true <- Todos.Repo.delete(todo_uid, :todos)
      do
        {:ok, args}
      else
        {:error, reason} ->
          Logger.warn(Atom.to_string(reason))
          {:error, @whoops}

        false ->
          Logger.warn("Not able to delete the Todo from database: %{todo_uid: #{todo_uid}}")
          {:error, @whoops}
    end
  end

  def delete_todo(_args, _context) do
    _handle_missing_user_for(:create_todo)
  end

  defp _build_todo_unique_id(todo_id, %{uid: user_uid} = _current_user) do
    Utils.sha256("#{todo_id}#{user_uid}")
  end

  defp _handle_missing_user_for(action) do
    Logger.debug("User missing in the context for action :#{action}?")
    {:error, @whoops}
  end
end

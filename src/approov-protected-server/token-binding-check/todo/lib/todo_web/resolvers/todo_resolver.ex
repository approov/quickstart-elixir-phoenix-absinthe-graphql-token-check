defmodule TodoWeb.TodoResolver do

  require Logger

  alias Todos.Todo

  def all_todos(_parent, _args, %{context: %{current_user: current_user}} = _resolver_info) do
    case Todos.User.authorized(:all_todos, current_user) do
      {:ok, _user} ->
        {:ok, Todo.all(:todos)}

      {:error, reason} ->
        Logger.warn(Atom.to_string(reason))
        {:error, "could not get all messages"}
    end
  end

  def create_todo(_parent, args, %{context: %{current_user: current_user}} = _resolver_info) do
    case Todos.User.authorized(:create_todo, current_user) do
      {:ok, _current_user} ->
        todo = %{
          id: System.unique_integer([:positive]),
          title: args.title,
          completed: false
        }

        Todo.insert(todo, :todos)

      {:error, reason} ->
        Logger.warn(Atom.to_string(reason))
        {:error, "could not create the todo"}
    end
  end

  def create_todo(_parent, _args, _resolver_info) do
    Logger.error("Current user not present in the Absinthe Context?")
    {:error, "you need to be logged in"}
  end

  def update_todo(_parent, args, _resolver_info) do
    todo = %{
      id: args.id,
      completed: args.completed
    }

    case Todo.update(todo, :todos) do
      :not_found ->
        {:error, :whoops}

      todo ->
        {:ok, todo}
    end
  end
end

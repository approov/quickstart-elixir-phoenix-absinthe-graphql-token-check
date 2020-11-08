defmodule TodoWeb.Schema do
  use Absinthe.Schema

  alias TodoWeb.TodoResolver

  require Logger

  object :todo do
    field :id, non_null(:integer)
    field :title, non_null(:string)
    field :is_completed, non_null(:boolean)
    field :is_public, non_null(:boolean)
    field :created_at, non_null(:string)
  end

  query do
    @desc "Get all todos"
    field :all_todos, non_null(list_of(non_null(:todo))) do
      resolve(&TodoResolver.all_todos/3)
    end

    @desc "Get all completed todos"
    field :completed_todos, non_null(list_of(non_null(:todo))) do
      resolve(&TodoResolver.completed_todos/3)
    end

    @desc "Get all active todos"
    field :active_todos, non_null(list_of(non_null(:todo))) do
      resolve(&TodoResolver.active_todos/3)
    end
  end

  mutation do
    @desc "Create a todo"
    field :create_todo, type: :todo do
      arg :title, non_null(:string)
      arg :is_public, non_null(:boolean)

      resolve(&TodoResolver.create_todo/3)
    end

    @desc "Toggle a todo"
    field :toggle_todo, :todo do
      arg :id, non_null(:integer)
      arg :is_completed, non_null(:boolean)

      resolve(&TodoResolver.toggle_todo/3)
    end

    @desc "Delete a todo"
    field :delete_todo, :todo do
      arg :id, non_null(:integer)

      resolve(&TodoResolver.delete_todo/3)
    end
  end

  subscription do
    field :todo_added, :todo do
      arg :topic, non_null(:string)

      config fn args, %{context: %{current_user: current_user}} = _resolver_info ->
        case Todos.User.authorized(:subscribe_todo_added, current_user) do
          {:ok, _current_user} ->
            {:ok, topic: args.topic}

          {:error, reason} ->
            Logger.warn(Atom.to_string(reason))
            {:error, "could not subscribe to the todo added event"}
        end
      end

      resolve fn todo, _, _ ->
        {:ok, todo}
      end
    end
  end
end

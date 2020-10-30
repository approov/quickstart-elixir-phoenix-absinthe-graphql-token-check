defmodule TodoWeb.Schema do
  use Absinthe.Schema

  alias TodoWeb.TodoResolver

  require Logger

  object :todo do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :completed, non_null(:boolean)
  end

  query do
    @desc "Get all todos"
    field :all_todos, non_null(list_of(non_null(:todo))) do
      resolve(&TodoResolver.all_todos/3)
    end
  end

  mutation do
    @desc "Create a todo"
    field :create_todo, type: :todo do
      arg :title, non_null(:string)
      arg :completed, non_null(:boolean)

      resolve(&TodoResolver.create_todo/3)
    end

    @desc "Update a todo"
    field :update_todo, :todo do
      arg :id, non_null(:id)
      arg :completed, non_null(:boolean)

      resolve(&TodoResolver.update_todo/3)
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

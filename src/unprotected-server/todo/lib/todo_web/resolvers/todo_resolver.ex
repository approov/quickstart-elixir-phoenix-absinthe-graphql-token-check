defmodule TodoWeb.TodoResolver do

  def all_todos(_parent, _args, %{context: context} = _resolver_info) do
    Todos.Context.all_todos(context)
  end

  def completed_todos(_parent, _args, %{context: context} = _resolver_info) do
    Todos.Context.completed_todos(context)
  end

  def active_todos(_parent, _args, %{context: context} = _resolver_info) do
    Todos.Context.active_todos(context)
  end

  def create_todo(_parent, args, %{context: context} = _resolver_info) do
    Todos.Context.create_todo(args, context)
  end

  def toggle_todo(_parent, args, %{context: context} = _resolver_info) do
    Todos.Context.toggle_todo(args, context)
  end

  def delete_todo(_parent, args, %{context: context} = _resolver_info) do
    Todos.Context.delete_todo(args, context)
  end

end

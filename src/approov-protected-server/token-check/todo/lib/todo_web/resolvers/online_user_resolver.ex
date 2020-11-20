defmodule TodoWeb.OnlineUserResolver do

  def all_users(_parent, _args, _resolver_info) do
    Todos.OnlineUser.all_users()
  end
end

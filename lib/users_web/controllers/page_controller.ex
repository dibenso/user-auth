defmodule UsersWeb.PageController do
  use UsersWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

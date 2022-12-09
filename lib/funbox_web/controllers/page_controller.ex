defmodule FunboxWeb.PageController do
  use FunboxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

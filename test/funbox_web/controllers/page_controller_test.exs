defmodule FunboxWeb.PageControllerTest do
  use FunboxWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Awesome Elixir!"
  end
end

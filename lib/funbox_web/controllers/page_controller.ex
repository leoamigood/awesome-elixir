defmodule FunboxWeb.PageController do
  use FunboxWeb, :controller

  alias Funbox.Awesome

  def index(conn, %{"min_stars" => stars}) do
    case Integer.parse(stars) do
      {number, _} -> awesome_elixir(conn, number)
      _ -> awesome_elixir(conn)
    end
  end

  def index(conn, _params), do: awesome_elixir(conn)

  defp awesome_elixir(conn, stars \\ 0) do
    case Awesome.latest_content() do
      nil -> render(conn, "empty.html")
      readme -> render(conn, "index.html", content: Awesome.enrich(readme.content, stars))
    end
  end
end

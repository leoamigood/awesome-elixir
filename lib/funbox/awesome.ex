defmodule Funbox.Awesome do
  @moduledoc false

  import Ecto.Query

  alias Funbox.ContentTransformer

  def latest_content do
    Funbox.Repo.one(from c in Funbox.Schemas.Content, order_by: [desc: c.inserted_at], limit: 1)
  end

  def enrich(content, min_stars) do
    {:ok, ast, _} =
      Base.decode64!(content, ignore: :whitespace, padding: false) |> EarmarkParser.as_ast()

    ast
    |> ContentTransformer.impl().transform(min_stars)
    |> Earmark.Transform.transform()
  end
end

defmodule Funbox.Awesome do
  @moduledoc false

  import Ecto.Query

  alias Funbox.ContentTransformer

  def latest_content do
    Funbox.Repo.one(from c in Funbox.Schemas.Content, order_by: [desc: c.inserted_at], limit: 1)
  end

  def enrich(content, min_stars \\ nil) do
    {:ok, ast, _} =
      Base.decode64!(content, ignore: :whitespace, padding: false) |> EarmarkParser.as_ast()

    ast
    |> ContentTransformer.impl().anchor()
    |> ContentTransformer.impl().section(Map.merge(section_awesomeness(min_stars), mandatory()))
    |> ContentTransformer.impl().stargaze(library_awesomeness())
    |> Earmark.Transform.transform()
  end

  defp library_awesomeness do
    Funbox.Schemas.Library
    |> select([l], {l.name, l.stargazers_count, l.updated_at})
    |> Funbox.Repo.all()
    |> Enum.reduce(%{}, fn {name, stars, since}, result ->
      Map.put(result, name, {stars, since})
    end)
  end

  defp section_awesomeness(stars) do
    Funbox.Schemas.Library
    |> group_by([p], p.section)
    |> select([p], {p.section, max(p.stargazers_count)})
    |> having(^maybe_requiring_stars(stars))
    |> Funbox.Repo.all()
    |> Enum.into(%{})
  end

  defp maybe_requiring_stars(stars) when is_nil(stars), do: true

  defp maybe_requiring_stars(stars) do
    dynamic([p], max(p.stargazers_count) >= ^stars)
  end

  defp mandatory do
    %{
      nil => true,
      "Resources" => true,
      "Books" => true,
      "Cheat Sheets" => true,
      "Community" => true,
      "Editors" => true,
      "Newsletters" => true,
      "Other Awesome Lists" => true,
      "Podcasts" => true,
      "Reading" => true,
      "Screencasts" => true,
      "Styleguides" => true,
      "Websites" => true,
      "Contributing" => true
    }
  end
end

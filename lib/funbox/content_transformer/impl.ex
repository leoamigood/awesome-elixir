defmodule Funbox.ContentTransformer.Impl do
  @moduledoc false

  @behaviour Funbox.ContentTransformer

  import Ecto.Query

  @spec transform(any(), integer) :: any()
  def transform(ast, min_stars) do
    ast
    |> anchor()
    |> section_filter(["Awesome Elixir" | section_awesomeness(min_stars)])
    |> library_filter(library_awesomeness(min_stars))
    |> stargaze(library_awesomeness(min_stars))
  end

  defp section_awesomeness(stars) do
    Funbox.Schemas.Library
    |> select([p], p.section)
    |> group_by([p], p.section)
    |> having([p], max(p.stargazers_count) >= ^stars)
    |> order_by([p], p.section)
    |> Funbox.Repo.all()
  end

  defp library_awesomeness(min_stars) do
    Funbox.Schemas.Library
    |> select([l], {l.name, l.stargazers_count, l.updated_at})
    |> where([l], l.stargazers_count >= ^min_stars)
    |> Funbox.Repo.all()
    |> Enum.reduce(%{}, fn {name, stars, since}, result ->
      Map.put(result, name, {stars, since})
    end)
  end

  def anchor(ast) do
    Earmark.Transform.map_ast(ast, &slugify(&1))
  end

  defp slugify({"h" <> <<_::bytes-size(1)>>, [], [name], %{}} = element) do
    Earmark.AstTools.merge_atts_in_node(element, id: name |> Slug.slugify())
  end

  defp slugify(element), do: element

  def stargaze(ast, awesomeness) do
    Earmark.Transform.map_ast(ast, &augment(&1, awesomeness))
  end

  defp augment({"ul", [], lis, %{}}, awesomeness) do
    {"ul", [], lis |> Enum.map(&augment(&1, awesomeness)), %{}}
  end

  defp augment({"li", [], anchors, %{}}, awesomeness) do
    {"li", [], anchors |> Enum.map(&augment(&1, awesomeness)), %{}}
  end

  defp augment(
         {"a", [{"href", "https://github.com/" <> _}], ["" <> repo], %{}} = anchor,
         awesomeness
       ) do
    {:replace, starify(anchor, repo, awesomeness)}
  end

  defp augment(element, _), do: element

  defp starify(anchor, repo, awesomeness) do
    case awesomeness[repo] do
      nil ->
        [anchor]

      {stars, since} ->
        [anchor] ++
          [
            " ⭐ #{stars} 📅 #{div(DateTime.diff(DateTime.utc_now(), since, :second), 24 * 60 * 60)}"
          ]
    end
  end

  def section_filter(ast, [head | _] = awesomeness) do
    Earmark.Transform.map_ast_with(ast, {awesomeness, head}, &suppress_section/2, true) |> elem(0)
  end

  defp suppress_section({e, _, [name], %{}} = element, {awesomeness, _}) when e in ["h1", "h2"],
    do: maybe_hide(awesomeness, name, element)

  defp suppress_section(
         {"li", _, [{"a", _, [name], %{}} | [{"ul", _, _, _}]], %{}} = element,
         {awesomeness, _}
       ),
       do: maybe_hide(awesomeness, name, element)

  defp suppress_section({"li", _, [{"a", _, [name], %{}}], %{}} = element, {awesomeness, _}),
    do: maybe_hide(awesomeness, name, element)

  defp suppress_section({e, _, _, %{}} = element, {awesomeness, name}) when e in ["ul", "p"],
    do: maybe_hide(awesomeness, name, element)

  defp suppress_section(element, accumulator), do: {element, accumulator}

  defp maybe_hide(awesomeness, name, element) do
    case Enum.member?(awesomeness, name) do
      false -> {hide(element), {awesomeness, name}}
      true -> {element, {awesomeness, name}}
    end
  end

  defp hide({e, attributes, name, %{}}) do
    {e, attributes ++ [{"style", "display: none"}], name, %{}}
  end

  def library_filter(ast, awesomeness) do
    Earmark.Transform.map_ast(ast, &suppress_library(&1, awesomeness))
  end

  defp suppress_library(
         {"li", _, [{"a", [{"href", "https://github.com/" <> _}], ["" <> repo], %{}} | _], %{}} =
           element,
         awesomeness
       ) do
    case awesomeness[repo] do
      nil -> hide(element)
      _ -> element
    end
  end

  defp suppress_library(
         {"li", _, [{"a", [{"href", "http" <> _}], _, %{}} | _], %{}} = element,
         _
       ),
       do: hide(element)

  defp suppress_library(element, _accumulator), do: element
end

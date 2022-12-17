defmodule Funbox.ContentTransformer.Impl do
  @moduledoc false

  @behaviour Funbox.ContentTransformer

  @spec anchor(any()) :: any()
  def anchor(ast) do
    Earmark.Transform.map_ast(ast, &idealize(&1))
  end

  defp idealize({"h" <> <<_::bytes-size(1)>>, [], [name], %{}} = element) do
    Earmark.AstTools.merge_atts_in_node(element, id: name |> Slug.slugify())
  end

  defp idealize(element), do: element

  @spec stargaze(any(), map) :: any()
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

  @spec section(any(), map) :: any()
  def section(ast, awesomeness) do
    Earmark.Transform.map_ast_with(ast, {awesomeness, nil}, &suppress/2, true) |> elem(0)
  end

  defp suppress({e, _, [name], %{}} = element, {awesomeness, _}) when e in ["h1", "h2"] do
    case awesomeness[name] do
      nil -> {hide(element), {awesomeness, name}}
      _ -> {element, {awesomeness, name}}
    end
  end

  defp suppress({"li", _, [{"a", _, [name], %{}}], %{}} = element, {awesomeness, nil}) do
    case awesomeness[name] do
      nil -> {hide(element), {awesomeness, nil}}
      _ -> {element, {awesomeness, nil}}
    end
  end

  defp suppress({e, _, _, %{}} = element, {awesomeness, section}) when e in ["ul", "p"] do
    case awesomeness[section] do
      nil -> {hide(element), {awesomeness, section}}
      _ -> {element, {awesomeness, section}}
    end
  end

  defp suppress(element, accumulator), do: {element, accumulator}

  defp hide({e, attributes, name, %{}}) do
    {e, attributes ++ [{"style", "display: none"}], name, %{}}
  end
end

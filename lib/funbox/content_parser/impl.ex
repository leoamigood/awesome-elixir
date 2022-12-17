defmodule Funbox.ContentParser.Impl do
  @moduledoc false

  @behaviour Funbox.ContentParser

  @spec libraries(String.t()) :: any()
  def libraries(content) do
    content
    |> decode64
    |> parse_markdown
    |> filter_libraries
  end

  defp decode64(content) do
    case Base.decode64(content, ignore: :whitespace) do
      :error -> {:error, ["Failed to Base64 decode #{content}"]}
      decoded -> decoded
    end
  end

  defp parse_markdown({:ok, content}) do
    case EarmarkParser.as_ast(String.replace(content, "\|", "\\|")) do
      {:ok, ast, _} -> {:ok, ast}
      {:error, ast, errors} -> {:error, ast, errors}
    end
  end

  defp parse_markdown({:error, errors}), do: {:error, errors}

  defp filter_libraries({:ok, ast}) do
    ast
    |> Enum.flat_map_reduce(nil, &headings(&1, &2))
    |> elem(0)
  end

  defp filter_libraries({:error, errors}), do: {:error, errors}

  defp headings({"h2", _, [name], _}, _) do
    {[], name}
  end

  defp headings({"h1", _, ["Resources"], _}, _) do
    {:halt, nil}
  end

  defp headings({"ul", _, lines, _}, section) do
    libraries =
      lines
      |> filter_github
      |> to_links(section)

    {libraries, section}
  end

  defp headings({_, _, _, _}, section) do
    {[], section}
  end

  defp filter_github(link) do
    link
    |> Enum.filter(
      &match?({"li", _, [{"a", [{"href", "https://github.com/" <> _}], _, _} | _], _}, &1)
    )
  end

  defp to_links(line, section) do
    line
    |> Enum.map(fn {"li", _, [{"a", [{"href", url}], [name], _} | _], _} ->
      %Link{section: section, name: name, url: url}
    end)
  end
end

defmodule Funbox.ContentTransformerTest do
  use Funbox.DataCase, async: true

  alias Funbox.ContentTransformer

  setup do
    Mock.allow_to_call_impl(ContentTransformer, :anchor, 1)
    Mock.allow_to_call_impl(ContentTransformer, :section, 2)
    Mock.allow_to_call_impl(ContentTransformer, :stargaze, 2)
    {:ok, readme, _} = File.read!('test/README.md') |> EarmarkParser.as_ast()

    {:ok, content: readme}
  end

  test "succeeded to append id anchor to heading nodes", %{content: content} do
    ast = ContentTransformer.impl().anchor(content)

    assert Enum.member?(ast, {"h2", [{"id", "actors"}], ["Actors"], %{}})
    assert Enum.member?(ast, {"h2", [{"id", "webassembly"}], ["WebAssembly"], %{}})
    assert Enum.member?(ast, {"h1", [{"id", "resources"}], ["Resources"], %{}})
    assert Enum.member?(ast, {"h2", [{"id", "books"}], ["Books"], %{}})
  end

  test "succeeded to hide sections based on awesomeness", %{content: content} do
    awesomeness = %{
      "Actors" => 100,
      "Applications" => 125,
      "Resources" => true
    }

    ast = ContentTransformer.impl().section(content, awesomeness)

    assert Enum.member?(ast, {"h2", [], ["Actors"], %{}})
    assert Enum.member?(ast, {"h2", [], ["Applications"], %{}})
    assert Enum.member?(ast, {"h1", [], ["Resources"], %{}})

    assert Enum.member?(ast, {"h2", [{"style", "display: none"}], ["Configuration"], %{}})
  end

  test "succeeded to augment libraries with stars and dates based on awesomeness", %{
    content: content
  } do
    awesomeness = %{
      "alf" => {121, DateTime.utc_now() |> DateTime.add(-10 * (24 * 60 * 60), :second)},
      "aeacus" => {36, DateTime.utc_now() |> DateTime.add(-25 * (24 * 60 * 60), :second)}
    }

    ast = ContentTransformer.impl().stargaze(content, awesomeness)

    alf =
      {"li", [],
       [
         [{"a", [{"href", "https://github.com/antonmi/ALF"}], ["alf"], %{}}, " ⭐ 121 📅 10"],
         " - Flow-based Application Layer Framework."
       ], %{}}

    aeacus =
      {"li", [],
       [
         [
           {"a", [{"href", "https://github.com/zmoshansky/aeacus"}], ["aeacus"], %{}},
           " ⭐ 36 📅 25"
         ],
         " - A simple configurable identity/password authentication module (Compatible with Ecto/Phoenix)."
       ], %{}}

    assert 1 == length(ast |> Enum.filter(&match?({"ul", [], [^alf | _], %{}}, &1)))
    assert 1 == length(ast |> Enum.filter(&match?({"ul", [], [^aeacus | _], %{}}, &1)))
  end
end

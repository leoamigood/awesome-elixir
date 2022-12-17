defmodule Funbox.AwesomeTest do
  use Funbox.DataCase, async: true

  @moduledoc false

  alias Funbox.Awesome
  alias Funbox.ContentTransformer

  import Hammox
  setup :verify_on_exit!

  setup do
    expect(ContentTransformer.impl(), :anchor, fn _ast -> [] end)
    expect(ContentTransformer.impl(), :section, fn _ast, _awesomeness -> [] end)
    expect(ContentTransformer.impl(), :stargaze, fn _ast, _awesomeness -> [] end)

    {:ok, content: File.read!('test/README.md') |> Base.encode64()}
  end

  test "successfully runs generation html execution flow", %{content: content} do
    Awesome.enrich(content)
  end
end

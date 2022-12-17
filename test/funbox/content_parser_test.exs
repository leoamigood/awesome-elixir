defmodule Funbox.ContentParserTest do
  use Funbox.DataCase, async: true

  alias Funbox.ContentParser

  import Hammox
  setup :verify_on_exit!

  setup do
    Mock.allow_to_call_impl(ContentParser, :libraries, 1)
    {:ok, content: File.read!('test/README.md') |> Base.encode64()}
  end

  test "succeeded to parse libraries", %{content: content} do
    libraries = ContentParser.impl().libraries(content)

    assert 1365 = length(libraries)

    assert %Link{section: "Actors", name: "alf", url: "https://github.com/antonmi/ALF"} =
             Enum.at(libraries, 0)

    assert %Link{section: "YAML", name: "yomel", url: "https://github.com/Joe-noh/yomel"} =
             Enum.at(libraries, -1)
  end

  test "failed to parse malformed content" do
    assert {:error, _errors} = ContentParser.impl().libraries("not_base64_encoded_content")
  end
end

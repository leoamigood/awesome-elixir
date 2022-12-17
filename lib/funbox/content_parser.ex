defmodule Funbox.ContentParser do
  @moduledoc false

  @implementation Application.compile_env!(:funbox, :content_parser)
  def impl, do: @implementation

  @callback libraries(String.t()) :: any()
end

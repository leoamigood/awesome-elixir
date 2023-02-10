defmodule Funbox.ContentTransformer do
  @moduledoc false

  @implementation Application.compile_env!(:funbox, :content_transformer)
  def impl, do: @implementation

  @callback transform(any(), integer) :: any()
end

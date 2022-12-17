defmodule Funbox.ContentTransformer do
  @moduledoc false

  @implementation Application.compile_env!(:funbox, :content_transformer)
  def impl, do: @implementation

  @callback anchor(any()) :: any()
  @callback section(any(), map) :: any()
  @callback stargaze(any(), map) :: any()
end

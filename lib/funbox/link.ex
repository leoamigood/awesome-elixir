defmodule Link do
  @moduledoc false

  @derive Jason.Encoder
  defstruct [:section, :name, :url]
end

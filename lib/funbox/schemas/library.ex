defmodule Funbox.Schemas.Library do
  @moduledoc """
  Stores repository stats information
  """

  use Ecto.Schema

  schema "libraries" do
    field(:name, :string)
    field(:section, :string)
    field(:stargazers_count, :integer)
    field(:updated_at, :utc_datetime)
  end
end

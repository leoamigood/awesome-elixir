defmodule Funbox.Schemas.Content do
  @moduledoc """
  Stores readme content
  """

  use Ecto.Schema

  schema "contents" do
    field(:name, :string)
    field(:content, :string)
    field(:encoding, :string)
    field(:download_url, :string)
    field(:sha, :string)
    field(:size, :integer)

    timestamps(type: :utc_datetime_usec)
  end
end

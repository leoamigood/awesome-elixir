defmodule Funbox.Repo.Migrations.CreateContentTable do
  use Ecto.Migration

  def change do
    create table("contents") do
      add :name, :string, null: false
      add :content, :text, null: false
      add :encoding, :string
      add :download_url, :string, null: false
      add :sha, :string, null: false
      add :size, :integer, null: false

      timestamps()
    end
  end
end

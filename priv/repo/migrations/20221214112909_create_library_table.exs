defmodule Funbox.Repo.Migrations.CreateLibraryTable do
  use Ecto.Migration

  def change do
    create table("libraries") do
      add :name, :string, null: false
      add :section, :string, null: false
      add :stargazers_count, :integer, null: false
      add :updated_at, :utc_datetime, null: false
    end
  end
end

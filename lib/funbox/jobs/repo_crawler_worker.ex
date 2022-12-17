defmodule Funbox.RepoCrawlerWorker do
  use Oban.Worker,
    priority: 3,
    queue: :crawler,
    tags: ["crawler"],
    unique: [period: 24 * 60 * 60, fields: [:args, :worker]]

  @moduledoc false

  require Logger

  alias Funbox.GithubClient

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "section" => section,
          "name" => name,
          "url" => "https://github.com/" <> owner_repo
        }
      }) do
    Logger.info("Crawling section #{section} library #{name}")
    [owner, repo] = String.split(owner_repo, "/") |> Enum.take(2)

    case GithubClient.impl().stats(owner, repo) do
      {:ok, resource} -> {:ok, create_or_update_library(section, name, resource)}
      {:error, %{status_code: 404}} -> {:cancel, %{reason: :not_found}}
      {:error, errors} -> {:error, errors}
    end
  end

  defp create_or_update_library(section, name, repo) do
    import Ecto.Changeset

    find_or_build_library(section, name)
    |> change(%{stargazers_count: repo.stargazers_count, updated_at: to_datetime(repo.updated_at)})
    |> Funbox.Repo.insert_or_update!()
  end

  defp find_or_build_library(section, name) do
    case Funbox.Repo.get_by(Funbox.Schemas.Library, name: name, section: section) do
      nil ->
        %Funbox.Schemas.Library{
          name: name,
          section: section
        }

      library ->
        library
    end
  end

  defp to_datetime(date_iso8601) do
    DateTime.from_iso8601(date_iso8601) |> elem(1)
  end
end

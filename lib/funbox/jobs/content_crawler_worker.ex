defmodule Funbox.ContentCrawlerWorker do
  use Oban.Worker,
    priority: 0,
    queue: :default,
    tags: ["crawler"],
    unique: [period: 24 * 60 * 60, fields: [:worker]]

  @moduledoc false

  require Logger

  alias Funbox.ContentParser
  alias Funbox.GithubClient

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    case GithubClient.impl().readme("h4cc", "awesome-elixir") do
      {:ok, resource} ->
        create_content(resource)

        resource.content
        |> ContentParser.impl().libraries()
        |> discover_links

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp create_content(resource) do
    Funbox.Repo.insert!(%Funbox.Schemas.Content{
      name: resource.name,
      content: resource.content,
      encoding: resource.encoding,
      download_url: resource.download_url,
      sha: resource.sha,
      size: resource.size
    })
  end

  defp discover_links(links) do
    Logger.info("Scheduling crawling for #{length(links)} links...")

    links
    |> Enum.with_index()
    |> Enum.each(fn {link, step} -> schedule_crawler(link, ticker(step, :second)) end)
  end

  # GitHub rate limits anonymous API requests (60 requests per hour)
  # and since Oban provides throttling only in Pro version
  # we have to workaround it by scheduling crawlers ahead of time
  def schedule_crawler(link, scheduled_at) do
    link
    |> Funbox.RepoCrawlerWorker.new(scheduled_at: scheduled_at)
    |> Oban.insert()
  end

  defp ticker(step, period) do
    DateTime.utc_now() |> DateTime.add(60 * step, period)
  end
end

defmodule Funbox.RepoCrawlerWorkerTest do
  use Funbox.DataCase, async: true
  use Oban.Testing, repo: Funbox.Repo

  alias Funbox.GithubClient

  import Hammox
  setup :verify_on_exit!

  test "succeeded to get repository stats" do
    expect(GithubClient.impl(), :stats, fn _user, _repo -> {:ok, repository()} end)
    #    Mock.allow_to_call_impl(GithubClient, :stats, 2)

    assert {:ok, _} =
             perform_job(Funbox.RepoCrawlerWorker, %{
               "section" => "YAML",
               "name" => "yomel",
               "url" => "https://github.com/Joe-noh/yomel"
             })
  end

  test "failed to get repository stats due to not found" do
    expect(GithubClient.impl(), :stats, fn _user, _repo -> {:error, %{status_code: 404}} end)

    assert {:cancel, %{reason: :not_found}} =
             perform_job(Funbox.RepoCrawlerWorker, %{
               "section" => "Algorithms and Data structures",
               "name" => "monad",
               "url" => "https://github.com/rmies/monad"
             })
  end

  test "failed to get repository stats due to server error" do
    expect(GithubClient.impl(), :stats, fn _user, _repo -> {:error, %{status_code: 500}} end)

    assert {:error, _reason} =
             perform_job(Funbox.RepoCrawlerWorker, %{
               "section" => "YAML",
               "name" => "yomel",
               "url" => "https://github.com/Joe-noh/yomel"
             })
  end

  def repository do
    %{
      name: "yomel",
      stargazers_count: 6,
      updated_at: "2019-01-28T20:32:43Z"
    }
  end
end

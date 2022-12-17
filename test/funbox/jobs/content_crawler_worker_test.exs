defmodule Funbox.ContentCrawlerWorkerTest do
  use Funbox.DataCase, async: true
  use Oban.Testing, repo: Funbox.Repo

  alias Funbox.ContentParser
  alias Funbox.GithubClient

  import Hammox
  setup :verify_on_exit!

  test "succeeded to get readme content" do
    expect(GithubClient.impl(), :readme, fn _user, _repo -> {:ok, content()} end)
    expect(ContentParser.impl(), :libraries, fn _content -> [] end)
    #    Mock.allow_to_call_impl(ContentParser, :libraries, 1)

    assert :ok = perform_job(Funbox.ContentCrawlerWorker, %{})
  end

  test "failed to get readme content" do
    expect(GithubClient.impl(), :readme, fn _user, _repo -> {:error, %{status_code: 500}} end)

    assert {:error, _} = perform_job(Funbox.ContentCrawlerWorker, %{})
  end

  def content do
    %{
      name: "README.md",
      content: File.read!('test/README.md') |> Base.encode64(),
      download_url: "https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md",
      encoding: "base64",
      sha: "4d0d2fbeaeb67dcb1f6a98cdeff904fc0feb93c9",
      size: 191_561
    }
  end
end

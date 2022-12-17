defmodule Funbox.GithubClient.Impl do
  @moduledoc false

  @behaviour Funbox.GithubClient

  @spec readme(String.t(), String.t()) :: {:ok, map} | {:error, map}
  def readme(user, repo) do
    case Tentacat.Contents.readme(user, repo) do
      {200, data, _response} -> {:ok, data}
      {_, _, errors} -> {:error, errors}
    end
  end

  @spec stats(String.t(), String.t()) :: {:ok, map} | {:error, map}
  def stats(user, repo) do
    case Tentacat.Repositories.repo_get(user, repo) do
      {200, data, _response} -> {:ok, data}
      {_, _, errors} -> {:error, errors}
    end
  end

  @spec last_commit(String.t(), String.t()) :: {:ok, map} | {:error, map}
  def last_commit(user, repo) do
    case Tentacat.Commits.list(user, repo) do
      {200, [latest | _], _response} -> {:ok, latest.commit}
      {_, _, errors} -> {:error, errors}
    end
  end
end

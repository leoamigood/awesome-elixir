defmodule Funbox.GithubClient do
  @moduledoc false

  @implementation Application.compile_env!(:funbox, :github_client)
  def impl, do: @implementation

  @callback readme(String.t(), String.t()) :: {:ok, map} | {:error, map}
  @callback stats(String.t(), String.t()) :: {:ok, map} | {:error, map}
  @callback last_commit(String.t(), String.t()) :: {:ok, map} | {:error, map}
end

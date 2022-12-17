# Awesome Elixir for FunBox

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

* Awesome repositories crawler starts at minight and might take up to a day for it to fully complete.
* In order to kick off crawling process prior to midnight use IEx as: `%{} |> Funbox.ContentCrawlerWorker.new() |> Oban.insert()`
* Keep in mind that GitHub is limiting anonymous calls with a rate of 60 requests per hour (per ip address).

In order to see this code running on production visit
[`https://awesome-elixir.fly.dev/`](https://awesome-elixir.fly.dev) from your browser

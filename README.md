# MarkYamill

A YAML decoder for Elixir.

## Get Up And Running

**Add it (to `mix.exs`)**

  ```elixir
  def deps do
    [{:mark_yamill, "~> 0.1.0"}]
  end
  ```

**Start it (in `mix.exs`)**

  ```elixir
  def application do
    [applications: [:mark_yamill]]
  end
  ```

**Download it**

  ```bash
  $ mix deps.get
  ```

**Run it!**

  ```bash
  $ iex -S mix
  iex(1)> yaml = "---\nfoo: bar\nhello: world\n"
  "---\nfoo: bar\nhello: world\n"
  iex(2)> MarkYamill.decode(yaml)
  %{"foo" => "bar", "hello" => "world"}
  ```

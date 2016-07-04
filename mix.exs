defmodule MarkYamill.Mixfile do
  use Mix.Project

  def project do
    [app: :mark_yamill,
     build_embedded: Mix.env == :prod,
     deps: deps(),
     elixir: "~> 1.3",
     version: "0.1.0",
     start_permanent: Mix.env == :prod]
  end

  def application do
    [applications: [:logger, :yamerl_the_fork]]
  end

  defp deps do
    [{:yamerl_the_fork, "~> 0.3.3"}]
  end
end

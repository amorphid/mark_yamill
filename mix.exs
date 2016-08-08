defmodule MarkYamill.Mixfile do
  use Mix.Project

  def application do
    [applications: [:logger, :yamerl]]
  end

  defp deps do
    [{:yamerl, "~> 0.3.2"}]
  end

  def project do
    [app: :mark_yamill,
     build_embedded: Mix.env == :prod,
     deps: deps(),
     description: "A YAML decoder for Elixir",
     elixir: "~> 1.3",
     package: package(),
     version: "0.1.0",
     start_permanent: Mix.env == :prod]
  end

  defp package do
    %{maintainers: ["Michael Pope"],
      licenses: ["Apache 2.0"],
      links: %{github: "https://github.com/amorphid/mark_yamill"}}
  end
end

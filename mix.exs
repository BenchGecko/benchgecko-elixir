defmodule BenchGecko.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/BenchGecko/benchgecko-elixir"

  def project do
    [
      app: :benchgecko,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "BenchGecko",
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.35", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    The CoinGecko for AI. Elixir client for AI model benchmarks, pricing comparison,
    cost estimation, and agent discovery. Query structured data on 300+ models across
    50+ providers with real benchmark scores and transparent pricing.
    """
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "Homepage" => "https://benchgecko.ai",
        "GitHub" => @source_url
      },
      maintainers: ["BenchGecko"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end
end

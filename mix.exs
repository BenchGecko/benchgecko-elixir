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
      package: package(),
      description: "Official Elixir SDK for the BenchGecko API. Compare AI models, benchmarks, and pricing.",
      name: "BenchGecko",
      source_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.4"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "Homepage" => "https://benchgecko.ai",
        "GitHub" => @source_url,
        "API Docs" => "https://benchgecko.ai/api-docs"
      },
      maintainers: ["BenchGecko"],
      files: ~w(lib mix.exs README.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end
end

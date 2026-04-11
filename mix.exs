defmodule BenchGecko.MixProject do
  use Mix.Project

  @version "0.1.2"
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
    "Official Elixir SDK for BenchGecko, the data layer of the AI economy. Thousands of models with cross-provider pricing, company valuations, benchmark scores, and a live changelog. If it moved in AI today, it's already on BenchGecko."
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

# BenchGecko Elixir SDK

Official Elixir client for the [BenchGecko](https://benchgecko.ai) API. Query AI model data, benchmark scores, and run side-by-side comparisons from Elixir applications.

BenchGecko tracks every major AI model, benchmark, and provider. This package wraps the public REST API with idiomatic Elixir patterns, tagged tuples, typespecs, and zero external HTTP dependencies (uses Erlang built-in `:httpc`).

## Installation

Add `benchgecko` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:benchgecko, "~> 0.1.0"}
  ]
end
```

## Quick Start

```elixir
# List all tracked AI models
{:ok, models} = BenchGecko.models()
IO.puts("Tracking #{length(models)} models")

# List all benchmarks
{:ok, benchmarks} = BenchGecko.benchmarks()
Enum.each(benchmarks, fn b -> IO.puts(b["name"]) end)

# Compare two models head-to-head
{:ok, comparison} = BenchGecko.compare(["gpt-4o", "claude-opus-4"])
comparison["models"]
|> Enum.each(fn m -> IO.puts("#{m["name"]}: #{inspect(m["scores"])}") end)
```

## API Reference

### `BenchGecko.models(opts \\ [])`

Fetch all AI models tracked by BenchGecko. Returns `{:ok, models}` where models is a list of maps with name, provider, benchmark scores, and pricing.

Options: `:base_url` (default `https://benchgecko.ai`), `:timeout` (default 30000ms).

### `BenchGecko.benchmarks(opts \\ [])`

Fetch all benchmarks tracked by BenchGecko. Returns `{:ok, benchmarks}` where benchmarks is a list of maps with name, category, and description.

### `BenchGecko.compare(model_slugs, opts \\ [])`

Compare two or more models side by side. Pass a list of model slugs (minimum 2). Returns `{:ok, comparison}` with per-model scores and pricing.

## Error Handling

All functions return tagged tuples following Elixir conventions:

```elixir
case BenchGecko.models() do
  {:ok, models} ->
    IO.puts("Got #{length(models)} models")

  {:error, %{status: status, body: body}} ->
    IO.puts("API error #{status}: #{body}")

  {:error, reason} ->
    IO.puts("Network error: #{inspect(reason)}")
end
```

## Configuration

Override the base URL for testing or self-hosted instances:

```elixir
{:ok, models} = BenchGecko.models(base_url: "http://localhost:3000")
```

## Data Attribution

Data provided by [BenchGecko](https://benchgecko.ai). Model benchmark scores are sourced from official evaluation suites. Pricing data is updated daily from provider APIs.

## Links

- [BenchGecko](https://benchgecko.ai) - AI model benchmarks, pricing, and rankings
- [API Documentation](https://benchgecko.ai/api-docs)
- [GitHub Repository](https://github.com/BenchGecko/benchgecko-elixir)

## License

MIT

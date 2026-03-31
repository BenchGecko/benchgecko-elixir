# `BenchGecko`
[🔗](https://github.com/BenchGecko/benchgecko-elixir/blob/v0.1.1/lib/benchgecko.ex#L1)

The CoinGecko for AI.

BenchGecko provides structured access to AI model benchmarks, pricing data,
and agent comparison. Query 300+ models across 50+ providers with real
benchmark scores, latency metrics, and transparent pricing.

## Quick Start

    model = BenchGecko.get_model("gpt-4o")
    model.name       #=> "GPT-4o"
    model.provider   #=> "OpenAI"

    BenchGecko.score(model, "MMLU")  #=> 88.7

## Comparing Models

    BenchGecko.compare_models("gpt-4o", "claude-3.5-sonnet")
    |> Map.get(:benchmark_diff)
    |> Enum.each(fn {bench, diff} -> IO.puts("#{bench}: #{diff}") end)

Full documentation at [benchgecko.ai](https://benchgecko.ai).

# `benchmark_categories`

```elixir
@spec benchmark_categories() :: map()
```

List all benchmark categories tracked by BenchGecko.

## Examples

    BenchGecko.benchmark_categories()
    |> Enum.each(fn {key, info} ->
      IO.puts("#{info.name}: #{Enum.join(info.benchmarks, ", ")}")
    end)

# `cheapest_above`

```elixir
@spec cheapest_above(String.t(), float()) :: BenchGecko.Model.t() | nil
```

Find the cheapest model that meets a minimum score on a benchmark.

## Examples

    model = BenchGecko.cheapest_above("MMLU", 85.0)
    IO.puts("#{model.name} at $#{BenchGecko.cost_per_million(model)}/M tokens")

# `compare_models`

```elixir
@spec compare_models(String.t(), String.t()) :: map() | :error
```

Compare two models side by side across benchmarks and pricing.

Returns a map with `:model_a`, `:model_b`, `:benchmark_diff`, `:cheaper`,
and `:cost_ratio`. Positive diff values mean model A scores higher.

## Examples

    result = BenchGecko.compare_models("gpt-4o", "claude-3.5-sonnet")
    result.cheaper
    #=> "gpt-4o"

    result.benchmark_diff
    |> Enum.filter(fn {_k, v} -> v != nil end)
    |> Enum.each(fn {bench, diff} ->
      IO.puts("#{bench}: #{diff}")
    end)

# `cost_per_million`

```elixir
@spec cost_per_million(BenchGecko.Model.t()) :: float() | nil
```

Calculate cost per million tokens (average of input and output).

## Examples

    model = BenchGecko.get_model!("gpt-4o")
    BenchGecko.cost_per_million(model)
    #=> 6.25

# `estimate_cost`

```elixir
@spec estimate_cost(String.t(), non_neg_integer(), non_neg_integer()) ::
  map() | :error
```

Estimate inference cost for a given token volume.

## Examples

    BenchGecko.estimate_cost("gpt-4o", 1_000_000, 500_000)
    #=> %{model: "GPT-4o", input_cost: 2.5, output_cost: 5.0, total: 7.5}

# `get_model`

```elixir
@spec get_model(String.t()) :: {:ok, BenchGecko.Model.t()} | :error
```

Retrieve a model by its identifier.

Returns `{:ok, model}` if found, `:error` otherwise.

## Examples

    {:ok, model} = BenchGecko.get_model("gpt-4o")
    model.name
    #=> "GPT-4o"

# `get_model!`

```elixir
@spec get_model!(String.t()) :: BenchGecko.Model.t()
```

Retrieve a model, raising if not found.

## Examples

    model = BenchGecko.get_model!("claude-3.5-sonnet")
    model.provider
    #=> "Anthropic"

# `list_models`

```elixir
@spec list_models() :: [String.t()]
```

List all available model identifiers.

## Examples

    BenchGecko.list_models()
    #=> ["claude-3.5-sonnet", "deepseek-v3", "gemini-2.0-flash", ...]

# `score`

```elixir
@spec score(BenchGecko.Model.t(), String.t()) :: float() | nil
```

Get the score for a specific benchmark on a model.

## Examples

    model = BenchGecko.get_model!("gpt-4o")
    BenchGecko.score(model, "MMLU")
    #=> 88.7

# `top_models`

```elixir
@spec top_models(String.t(), float()) :: [BenchGecko.Model.t()]
```

Find models scoring above a threshold on a given benchmark.

Results are sorted by score descending.

## Examples

    BenchGecko.top_models("MMLU", 87.0)
    |> Enum.each(fn m -> IO.puts("#{m.name}: #{BenchGecko.score(m, "MMLU")}") end)

---

*Consult [api-reference.md](api-reference.md) for complete listing*

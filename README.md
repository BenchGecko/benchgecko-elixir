# BenchGecko for Elixir

**The data layer of the AI economy.** Official Elixir SDK for [BenchGecko](https://benchgecko.ai).

Query thousands of AI models with cross-provider pricing and daily price history. Track company valuations, funding timelines, and revenue estimates. Pull benchmark scores, agent leaderboards, and a live changelog of every price drop, every launch, every deprecation. If it moved in AI today, it's already on BenchGecko.

This package gives you structured access to that data in idiomatic Elixir with pattern matching, pipes, and typespecs throughout.

## Installation

Add `benchgecko` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:benchgecko, "~> 0.1.0"}
  ]
end
```

Then run `mix deps.get`.

## Quick Start

```elixir
# Look up any model
{:ok, model} = BenchGecko.get_model("claude-3.5-sonnet")
model.name       #=> "Claude 3.5 Sonnet"
model.provider   #=> "Anthropic"

BenchGecko.score(model, "MMLU")  #=> 88.7

# Bang variant raises on unknown models
model = BenchGecko.get_model!("gpt-4o")
```

## Comparing Models

The comparison engine uses Elixir maps to surface benchmark differences and pricing ratios. Positive diff values mean the first model scores higher:

```elixir
"gpt-4o"
|> BenchGecko.compare_models("claude-3.5-sonnet")
|> then(fn result ->
  IO.puts("Cheaper: #{result.cheaper}")
  IO.puts("Cost ratio: #{result.cost_ratio}")

  result.benchmark_diff
  |> Enum.filter(fn {_bench, diff} -> diff != nil end)
  |> Enum.each(fn {bench, diff} ->
    winner = if diff >= 0, do: "GPT-4o", else: "Claude 3.5 Sonnet"
    IO.puts("#{bench}: #{winner} by #{abs(diff)} pts")
  end)
end)
```

## Cost Estimation

Estimate inference costs before committing to a provider. All prices are per million tokens:

```elixir
case BenchGecko.estimate_cost("gpt-4o", 2_000_000, 500_000) do
  %{total: total, input_cost: input, output_cost: output} ->
    IO.puts("Input: $#{input}, Output: $#{output}, Total: $#{total}")

  :error ->
    IO.puts("Model not found or missing pricing data")
end
```

## Finding the Right Model

Filter models by benchmark performance with pipes and pattern matching:

```elixir
# All models scoring 87+ on MMLU, sorted by score
BenchGecko.top_models("MMLU", 87.0)
|> Enum.each(fn model ->
  IO.puts("#{model.name}: #{BenchGecko.score(model, "MMLU")}")
end)

# Cheapest model above a quality threshold
case BenchGecko.cheapest_above("MMLU", 85.0) do
  nil -> IO.puts("No model meets the threshold")
  model -> IO.puts("#{model.name} at $#{BenchGecko.cost_per_million(model)}/M tokens")
end
```

## Benchmark Categories

BenchGecko organizes benchmarks into categories covering reasoning, coding, math, instruction following, safety, multimodal, multilingual, and long context evaluation:

```elixir
BenchGecko.benchmark_categories()
|> Enum.each(fn {_key, info} ->
  IO.puts("#{info.name}: #{Enum.join(info.benchmarks, ", ")}")
  IO.puts("  #{info.description}")
end)
```

## Built-in Model Catalog

The package ships with a curated catalog of major models from every leading lab, including OpenAI, Anthropic, Google, Meta, Mistral, and DeepSeek. Each entry includes benchmark scores, parameter counts, context window sizes, and per-token pricing.

All data is compiled into the module at build time for zero-overhead lookups. No HTTP calls, no external dependencies.

```elixir
model = BenchGecko.get_model!("deepseek-v3")
model.parameters       #=> 671
model.context_window   #=> 128_000
BenchGecko.cost_per_million(model)  #=> 0.685
```

## Typespecs and Documentation

Every public function has `@spec` and `@doc` annotations. Generate local documentation with:

```bash
mix docs
```

## Resources

- [BenchGecko](https://benchgecko.ai). Full platform with interactive comparisons.
- [Source Code](https://github.com/BenchGecko/benchgecko-elixir). Contributions welcome.

## License

MIT License. See [LICENSE](LICENSE) for details.

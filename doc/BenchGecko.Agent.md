# `BenchGecko.Agent`
[🔗](https://github.com/BenchGecko/benchgecko-elixir/blob/v0.1.1/lib/benchgecko.ex#L58)

Represents an AI agent with capabilities and evaluation scores.

# `t`

```elixir
@type t() :: %BenchGecko.Agent{
  capabilities: [String.t()],
  category: String.t(),
  id: String.t(),
  metadata: map(),
  models_used: [String.t()],
  name: String.t(),
  provider: String.t(),
  scores: map()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

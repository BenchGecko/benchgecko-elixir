# `BenchGecko.Model`
[🔗](https://github.com/BenchGecko/benchgecko-elixir/blob/v0.1.1/lib/benchgecko.ex#L28)

Represents an AI model with benchmark scores, pricing, and metadata.

# `t`

```elixir
@type t() :: %BenchGecko.Model{
  benchmarks: map(),
  context_window: integer() | nil,
  id: String.t(),
  input_price: float() | nil,
  metadata: map(),
  name: String.t(),
  output_price: float() | nil,
  parameters: number() | nil,
  provider: String.t()
}
```

---

*Consult [api-reference.md](api-reference.md) for complete listing*

defmodule BenchGecko do
  @moduledoc """
  Official Elixir SDK for the BenchGecko API.

  BenchGecko tracks every major AI model, benchmark, and provider.
  This library wraps the public REST API so you can query model data,
  benchmark scores, and run comparisons from Elixir applications.

  ## Quick Start

      # List all AI models
      {:ok, models} = BenchGecko.models()
      IO.puts("Tracking \#{length(models)} models")

      # List all benchmarks
      {:ok, benchmarks} = BenchGecko.benchmarks()

      # Compare two models
      {:ok, comparison} = BenchGecko.compare(["gpt-4o", "claude-opus-4"])

  ## Configuration

  Pass options to override the default base URL:

      {:ok, models} = BenchGecko.models(base_url: "http://localhost:3000")
  """

  @default_base_url "https://benchgecko.ai"
  @user_agent ~c"benchgecko-elixir/0.1.0"

  @type option :: {:base_url, String.t()} | {:timeout, pos_integer()}
  @type options :: [option()]

  @doc """
  List all AI models tracked by BenchGecko.

  Returns `{:ok, models}` where `models` is a list of maps containing
  model metadata, benchmark scores, and pricing information.

  ## Options

    * `:base_url` - Override the API base URL (default: `https://benchgecko.ai`)
    * `:timeout` - HTTP timeout in milliseconds (default: 30000)

  ## Examples

      {:ok, models} = BenchGecko.models()
      Enum.each(models, fn m -> IO.puts(m["name"]) end)
  """
  @spec models(options()) :: {:ok, list(map())} | {:error, term()}
  def models(opts \\ []) do
    request("/api/v1/models", %{}, opts)
  end

  @doc """
  List all benchmarks tracked by BenchGecko.

  Returns `{:ok, benchmarks}` where `benchmarks` is a list of maps
  with benchmark name, category, and description.

  ## Examples

      {:ok, benchmarks} = BenchGecko.benchmarks()
      Enum.each(benchmarks, fn b -> IO.puts(b["name"]) end)
  """
  @spec benchmarks(options()) :: {:ok, list(map())} | {:error, term()}
  def benchmarks(opts \\ []) do
    request("/api/v1/benchmarks", %{}, opts)
  end

  @doc """
  Compare two or more AI models side by side.

  Accepts a list of model slugs (minimum 2) and returns a structured
  comparison with per-model scores, pricing, and capabilities.

  ## Examples

      {:ok, result} = BenchGecko.compare(["gpt-4o", "claude-opus-4"])
      result["models"]
      |> Enum.each(fn m -> IO.puts("\#{m["name"]}: \#{inspect(m["scores"])}") end)
  """
  @spec compare(list(String.t()), options()) :: {:ok, map()} | {:error, term()}
  def compare(model_slugs, opts \\ []) when is_list(model_slugs) do
    if length(model_slugs) < 2 do
      {:error, "At least 2 models are required for comparison"}
    else
      params = %{"models" => Enum.join(model_slugs, ",")}
      request("/api/v1/compare", params, opts)
    end
  end

  defp request(path, params, opts) do
    base_url = Keyword.get(opts, :base_url, @default_base_url) |> String.trim_trailing("/")
    timeout = Keyword.get(opts, :timeout, 30_000)

    query =
      params
      |> Enum.map(fn {k, v} -> "#{URI.encode(k)}=#{URI.encode(v)}" end)
      |> Enum.join("&")

    url =
      if query == "" do
        ~c"#{base_url}#{path}"
      else
        ~c"#{base_url}#{path}?#{query}"
      end

    http_opts = [
      timeout: timeout,
      connect_timeout: timeout,
      ssl: [verify: :verify_none]
    ]

    headers = [
      {~c"user-agent", @user_agent},
      {~c"accept", ~c"application/json"}
    ]

    case :httpc.request(:get, {url, headers}, http_opts, []) do
      {:ok, {{_, status, _}, _headers, body}} when status >= 200 and status < 300 ->
        Jason.decode(IO.iodata_to_binary(body))

      {:ok, {{_, status, _}, _headers, body}} ->
        {:error, %{status: status, body: IO.iodata_to_binary(body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

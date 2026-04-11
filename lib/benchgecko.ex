defmodule BenchGecko do
  @moduledoc """
  The data layer of the AI economy.

  BenchGecko provides structured access to thousands of AI models with
  cross-provider pricing, daily price history, benchmark scores, company
  valuations, funding timelines, and agent leaderboards. If it moved in AI
  today, it's already on BenchGecko.

  ## Quick Start

      model = BenchGecko.get_model("gpt-4o")
      model.name       #=> "GPT-4o"
      model.provider   #=> "OpenAI"

      BenchGecko.score(model, "MMLU")  #=> 88.7

  ## Comparing Models

      BenchGecko.compare_models("gpt-4o", "claude-3.5-sonnet")
      |> Map.get(:benchmark_diff)
      |> Enum.each(fn {bench, diff} -> IO.puts("\#{bench}: \#{diff}") end)

  Full documentation at [benchgecko.ai](https://benchgecko.ai).
  """

  @version "0.1.2"

  defmodule Model do
    @moduledoc """
    Represents an AI model with benchmark scores, pricing, and metadata.
    """

    @type t :: %__MODULE__{
            id: String.t(),
            name: String.t(),
            provider: String.t(),
            parameters: number() | nil,
            context_window: integer() | nil,
            input_price: float() | nil,
            output_price: float() | nil,
            benchmarks: map(),
            metadata: map()
          }

    defstruct [
      :id,
      :name,
      :provider,
      :parameters,
      :context_window,
      :input_price,
      :output_price,
      benchmarks: %{},
      metadata: %{}
    ]
  end

  defmodule Agent do
    @moduledoc """
    Represents an AI agent with capabilities and evaluation scores.
    """

    @type t :: %__MODULE__{
            id: String.t(),
            name: String.t(),
            category: String.t(),
            provider: String.t(),
            models_used: [String.t()],
            scores: map(),
            capabilities: [String.t()],
            metadata: map()
          }

    defstruct [
      :id,
      :name,
      :category,
      :provider,
      models_used: [],
      scores: %{},
      capabilities: [],
      metadata: %{}
    ]
  end

  @models %{
    "gpt-4o" => %{
      name: "GPT-4o",
      provider: "OpenAI",
      parameters: 200,
      context_window: 128_000,
      input_price: 2.50,
      output_price: 10.00,
      benchmarks: %{"MMLU" => 88.7, "HumanEval" => 90.2, "GSM8K" => 95.8, "GPQA" => 53.6}
    },
    "claude-3.5-sonnet" => %{
      name: "Claude 3.5 Sonnet",
      provider: "Anthropic",
      parameters: nil,
      context_window: 200_000,
      input_price: 3.00,
      output_price: 15.00,
      benchmarks: %{"MMLU" => 88.7, "HumanEval" => 92.0, "GSM8K" => 96.4, "GPQA" => 59.4}
    },
    "gemini-2.0-flash" => %{
      name: "Gemini 2.0 Flash",
      provider: "Google",
      parameters: nil,
      context_window: 1_000_000,
      input_price: 0.10,
      output_price: 0.40,
      benchmarks: %{"MMLU" => 85.2, "HumanEval" => 84.0, "GSM8K" => 92.1}
    },
    "llama-3.1-405b" => %{
      name: "Llama 3.1 405B",
      provider: "Meta",
      parameters: 405,
      context_window: 128_000,
      input_price: 3.00,
      output_price: 3.00,
      benchmarks: %{"MMLU" => 88.6, "HumanEval" => 89.0, "GSM8K" => 96.8, "GPQA" => 50.7}
    },
    "mistral-large" => %{
      name: "Mistral Large",
      provider: "Mistral",
      parameters: 123,
      context_window: 128_000,
      input_price: 2.00,
      output_price: 6.00,
      benchmarks: %{"MMLU" => 84.0, "HumanEval" => 82.0, "GSM8K" => 91.2}
    },
    "deepseek-v3" => %{
      name: "DeepSeek V3",
      provider: "DeepSeek",
      parameters: 671,
      context_window: 128_000,
      input_price: 0.27,
      output_price: 1.10,
      benchmarks: %{"MMLU" => 87.1, "HumanEval" => 82.6, "GSM8K" => 89.3, "GPQA" => 59.1}
    }
  }

  @benchmark_categories %{
    reasoning: %{
      name: "Reasoning",
      benchmarks: ["MMLU", "MMLU-Pro", "ARC-Challenge", "HellaSwag", "WinoGrande", "GPQA"],
      description: "Logical reasoning, knowledge, and common sense"
    },
    coding: %{
      name: "Coding",
      benchmarks: ["HumanEval", "MBPP", "SWE-bench", "LiveCodeBench", "BigCodeBench"],
      description: "Code generation, debugging, and software engineering"
    },
    math: %{
      name: "Mathematics",
      benchmarks: ["GSM8K", "MATH", "AIME", "AMC", "Competition-Math"],
      description: "Mathematical problem solving from arithmetic to olympiad"
    },
    instruction: %{
      name: "Instruction Following",
      benchmarks: ["IFEval", "MT-Bench", "AlpacaEval", "Chatbot-Arena"],
      description: "Following complex instructions and conversational ability"
    },
    safety: %{
      name: "Safety",
      benchmarks: ["TruthfulQA", "BBQ", "ToxiGen", "BOLD"],
      description: "Truthfulness, bias, and safety alignment"
    },
    multimodal: %{
      name: "Multimodal",
      benchmarks: ["MMMU", "MathVista", "VQAv2", "TextVQA", "DocVQA"],
      description: "Vision, document understanding, and cross-modal reasoning"
    },
    multilingual: %{
      name: "Multilingual",
      benchmarks: ["MGSM", "XL-Sum", "FLORES"],
      description: "Performance across languages and translation"
    },
    long_context: %{
      name: "Long Context",
      benchmarks: ["RULER", "NIAH", "InfiniteBench", "LongBench"],
      description: "Retrieval and reasoning over long documents"
    }
  }

  @doc """
  Retrieve a model by its identifier.

  Returns `{:ok, model}` if found, `:error` otherwise.

  ## Examples

      {:ok, model} = BenchGecko.get_model("gpt-4o")
      model.name
      #=> "GPT-4o"

  """
  @spec get_model(String.t()) :: {:ok, Model.t()} | :error
  def get_model(model_id) do
    case Map.get(@models, model_id) do
      nil -> :error
      data -> {:ok, struct(Model, Map.put(data, :id, model_id))}
    end
  end

  @doc """
  Retrieve a model, raising if not found.

  ## Examples

      model = BenchGecko.get_model!("claude-3.5-sonnet")
      model.provider
      #=> "Anthropic"

  """
  @spec get_model!(String.t()) :: Model.t()
  def get_model!(model_id) do
    case get_model(model_id) do
      {:ok, model} -> model
      :error -> raise ArgumentError, "Unknown model: #{model_id}"
    end
  end

  @doc """
  List all available model identifiers.

  ## Examples

      BenchGecko.list_models()
      #=> ["claude-3.5-sonnet", "deepseek-v3", "gemini-2.0-flash", ...]

  """
  @spec list_models() :: [String.t()]
  def list_models, do: Map.keys(@models) |> Enum.sort()

  @doc """
  Get the score for a specific benchmark on a model.

  ## Examples

      model = BenchGecko.get_model!("gpt-4o")
      BenchGecko.score(model, "MMLU")
      #=> 88.7

  """
  @spec score(Model.t(), String.t()) :: float() | nil
  def score(%Model{benchmarks: benchmarks}, benchmark_name) do
    Map.get(benchmarks, benchmark_name)
  end

  @doc """
  Calculate cost per million tokens (average of input and output).

  ## Examples

      model = BenchGecko.get_model!("gpt-4o")
      BenchGecko.cost_per_million(model)
      #=> 6.25

  """
  @spec cost_per_million(Model.t()) :: float() | nil
  def cost_per_million(%Model{input_price: inp, output_price: out})
      when is_number(inp) and is_number(out) do
    Float.round((inp + out) / 2.0, 4)
  end

  def cost_per_million(_), do: nil

  @doc """
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
        IO.puts("\#{bench}: \#{diff}")
      end)

  """
  @spec compare_models(String.t(), String.t()) :: map() | :error
  def compare_models(id_a, id_b) do
    with {:ok, a} <- get_model(id_a),
         {:ok, b} <- get_model(id_b) do
      all_benchmarks =
        (Map.keys(a.benchmarks) ++ Map.keys(b.benchmarks))
        |> Enum.uniq()

      benchmark_diff =
        all_benchmarks
        |> Enum.map(fn bench ->
          sa = Map.get(a.benchmarks, bench)
          sb = Map.get(b.benchmarks, bench)

          diff =
            if sa && sb,
              do: Float.round(sa - sb, 2),
              else: nil

          {bench, diff}
        end)
        |> Map.new()

      cost_a = cost_per_million(a)
      cost_b = cost_per_million(b)

      cheaper =
        cond do
          is_nil(cost_a) or is_nil(cost_b) -> nil
          cost_a <= cost_b -> id_a
          true -> id_b
        end

      cost_ratio =
        if cost_a && cost_b && cost_b > 0,
          do: Float.round(cost_a / cost_b, 2),
          else: nil

      %{
        model_a: summarize(a),
        model_b: summarize(b),
        benchmark_diff: benchmark_diff,
        cheaper: cheaper,
        cost_ratio: cost_ratio
      }
    else
      _ -> :error
    end
  end

  @doc """
  Estimate inference cost for a given token volume.

  ## Examples

      BenchGecko.estimate_cost("gpt-4o", 1_000_000, 500_000)
      #=> %{model: "GPT-4o", input_cost: 2.5, output_cost: 5.0, total: 7.5}

  """
  @spec estimate_cost(String.t(), non_neg_integer(), non_neg_integer()) :: map() | :error
  def estimate_cost(model_id, input_tokens, output_tokens \\ 0) do
    case get_model(model_id) do
      {:ok, %Model{input_price: inp, output_price: out} = model}
      when is_number(inp) and is_number(out) ->
        input_cost = Float.round(inp * input_tokens / 1_000_000, 4)
        output_cost = Float.round(out * output_tokens / 1_000_000, 4)

        %{
          model: model.name,
          input_tokens: input_tokens,
          output_tokens: output_tokens,
          input_cost: input_cost,
          output_cost: output_cost,
          total: Float.round(input_cost + output_cost, 4)
        }

      _ ->
        :error
    end
  end

  @doc """
  List all benchmark categories tracked by BenchGecko.

  ## Examples

      BenchGecko.benchmark_categories()
      |> Enum.each(fn {key, info} ->
        IO.puts("\#{info.name}: \#{Enum.join(info.benchmarks, ", ")}")
      end)

  """
  @spec benchmark_categories() :: map()
  def benchmark_categories, do: @benchmark_categories

  @doc """
  Find models scoring above a threshold on a given benchmark.

  Results are sorted by score descending.

  ## Examples

      BenchGecko.top_models("MMLU", 87.0)
      |> Enum.each(fn m -> IO.puts("\#{m.name}: \#{BenchGecko.score(m, "MMLU")}") end)

  """
  @spec top_models(String.t(), float()) :: [Model.t()]
  def top_models(benchmark, min_score \\ 0.0) do
    @models
    |> Enum.filter(fn {_id, data} ->
      s = Map.get(data.benchmarks, benchmark)
      s != nil and s >= min_score
    end)
    |> Enum.map(fn {id, _data} -> get_model!(id) end)
    |> Enum.sort_by(fn m -> -score(m, benchmark) end)
  end

  @doc """
  Find the cheapest model that meets a minimum score on a benchmark.

  ## Examples

      model = BenchGecko.cheapest_above("MMLU", 85.0)
      IO.puts("\#{model.name} at $\#{BenchGecko.cost_per_million(model)}/M tokens")

  """
  @spec cheapest_above(String.t(), float()) :: Model.t() | nil
  def cheapest_above(benchmark, min_score) do
    top_models(benchmark, min_score)
    |> Enum.filter(&cost_per_million/1)
    |> Enum.min_by(&cost_per_million/1, fn -> nil end)
  end

  defp summarize(%Model{} = m) do
    %{
      name: m.name,
      provider: m.provider,
      parameters: m.parameters,
      context_window: m.context_window,
      cost_per_million: cost_per_million(m)
    }
  end
end

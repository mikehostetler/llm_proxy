defmodule LLMProxy.UsageTest do
  use ExUnit.Case, async: true

  alias LLMProxy.Usage

  test "renders OpenAI usage from internal usage struct" do
    usage = Usage.new(10, 4, 3)

    assert Usage.to_openai(usage) == %{
             "prompt_tokens" => 13,
             "completion_tokens" => 4,
             "total_tokens" => 17,
             "prompt_tokens_details" => %{"cached_tokens" => 3}
           }
  end

  test "OpenAI and Responses inputs normalize cached tokens exactly once" do
    chat = %{
      "prompt_tokens" => 10_000,
      "completion_tokens" => 100,
      "prompt_tokens_details" => %{"cached_tokens" => 9_000}
    }

    responses = %{
      "input_tokens" => 10_000,
      "output_tokens" => 100,
      "input_tokens_details" => %{"cached_tokens" => 9_000}
    }

    expected = Usage.new(1_000, 100, 9_000)
    assert Usage.from_openai(chat) == expected
    assert Usage.from_responses(responses) == expected
    assert Usage.to_openai(expected) |> Usage.from_openai() == expected
    assert Usage.to_responses(expected) |> Usage.from_responses() == expected
  end

  test "renders Responses usage from ReqLLM usage maps" do
    usage = %{input_tokens: 10, output_tokens: 4, cache_read_tokens: 3}

    assert Usage.to_responses(usage) == %{
             "input_tokens" => 10,
             "output_tokens" => 4,
             "total_tokens" => 14,
             "input_tokens_details" => %{"cached_tokens" => 3}
           }
  end
end

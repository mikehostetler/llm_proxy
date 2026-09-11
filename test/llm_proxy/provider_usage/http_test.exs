defmodule LLMProxy.ProviderUsage.HTTPTest do
  use ExUnit.Case, async: true

  alias LLMProxy.ProviderUsage.HTTP

  test "uses Finch connection options without the incompatible connect_options alias" do
    request = HTTP.build_request("https://example.invalid/usage", [], 1_234)
    refute Map.has_key?(request.options, :connect_options)
    assert request.options[:finch][:conn_opts][:transport_opts][:timeout] == 1_234
    assert request.options[:finch][:pool_timeout] == 1_234
    assert request.options[:receive_timeout] == 1_234
    assert request.options[:retry] == false
    assert request.options[:redirect] == false
  end
end

defmodule AssertHtml.Matcher do

  import ExUnit.Assertions, only: [assert: 2, refute: 2]
  alias AssertHtml
  alias AssertHtml.Parser

  @typep assert_or_refute :: :assert | :refute

  @spec selector(assert_or_refute, AssertHtml.html, AssertHtml.selector) :: AssertHtml.response
  def selector(matcher, html, selector) do
    doc = Parser.find(html, selector)
    match!(matcher, doc != [], "Selector `#{selector}` not found:\n Result HTML: #{html}")
    doc
  end

  def assert_attributes(html, selector, attributes) do
    # TODO

  end

  def match_text(matcher, html, selector, value) do
    selected_html = selector(matcher, html, selector) |> Parser.to_html()
    match_text(matcher, selected_html, value)
  end

  def match_text(matcher, html, value) do
    str_value = to_string(value)
    match! matcher, html =~ str_value, "Error not found `#{value}` value: #{html}"
  end

  defp match(check, condition) do
    cond do
      check == :assert and condition -> true
      check == :refute and !condition -> true
      true -> false
    end
  end

  defp match!(check, condition, message) do
    if match(check, condition) do
      raise ExUnit.AssertionError,
      expr: "expr",
      message: message
    end
  end

end

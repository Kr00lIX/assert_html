defmodule AssertHtml.Matcher do
  @moduledoc false

  alias AssertHtml
  alias AssertHtml.{Parser, Selector}

  @typep assert_or_refute :: :assert | :refute

  @spec selector(assert_or_refute, AssertHtml.html(), AssertHtml.css_selector()) ::
          AssertHtml.html() | no_return()
  def selector(matcher, html, selector) do
    doc = Parser.find(html, selector)
    match!(matcher, doc == [], fn
      :assert -> "Selector `#{selector}` not found in HTML\n #{html}"
      :refute -> "Selector `#{selector}` succeeded, but should have failed.\n #{html}\n"
    end)

    doc
  end

  def assert_attributes(html, _selector, _attributes) do
    # TODO

    html
  end

  def compare_text(matcher, text, value) do
    match!(matcher, text == value, fn
      :assert -> [message: "Selector  not found in HTML\n #{text}", left: text, right: value]
      :refute -> ""
    end)
  end

  def compare_text(matcher, html, selector, value) do
    text = Selector.text(html, selector)
    compare_text(matcher, html, value)
  end

  def match_text(matcher, html, selector, value) do
    selected_html = selector(matcher, html, selector) |> Parser.to_html()
    match_text(matcher, selected_html, value)
  end

  def match_text(matcher, html, value) do
    str_value = to_string(value)
    [str_value: str_value, html: html] |> IO.inspect()
    match!(matcher, html =~ str_value, "Error not found `#{value}` value: #{html}")
  end

  defp match(check, condition) do
    cond do
      check == :assert -> condition
      check == :refute -> !condition
      true -> false
    end
    |> IO.inspect(label: "match #{inspect condition}")
  end

  defp match!(check, condition, message_fn) do
    if match(check, condition) do
      message = is_function(message_fn) && message_fn.(check) || message_fn

      raise ExUnit.AssertionError, message: message
    end
  end
end

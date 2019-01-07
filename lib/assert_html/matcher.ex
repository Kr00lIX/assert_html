defmodule AssertHtml.Matcher do
  @moduledoc false

  alias AssertHtml
  alias AssertHtml.{HTML, Parser, Selector}

  @typep assert_or_refute :: :assert | :refute

  @spec selector(assert_or_refute, AssertHtml.html(), AssertHtml.css_selector()) :: no_return()
  def selector(matcher, html, selector) do
    doc = Parser.find(html, selector)
    raise_match(matcher, doc == [], fn
      :assert -> "Element `#{selector}` not found.\n#{html}"
      :refute -> "Selector `#{selector}` succeeded, but should have failed.\n\n#{html}\n"
    end)
    doc
  end

  def match_text(matcher, html, selector, value) do
    doc = Parser.find(html, selector)

    # ignore if element not found for :refute
    if matcher == :assert do
      raise_match(matcher, doc == [], fn _matcher ->
        "Element `#{selector}` not found.\n#{html}"
      end)
    end

    selected_html = Parser.to_html(doc)
    match_text(matcher, selected_html, value)
  end

  def match_text(matcher, html_element, %Regex{} = value) do
    text = Parser.text(html_element)

    raise_match(matcher, !Regex.match?(value, text), fn
      :assert ->
        [message: "Match failed #{inspect(value)} in `#{text}`.\n\nHTML element: #{html_element}.", expr: "#{text} =~ #{inspect(value)}"]
      :refute ->
        [message: "Text matched, but should haven't matched.\n\nHTML element: #{html_element}.", expr: "#{text} =~ #{inspect(value)}"]
    end)
  end

  def match_text(matcher, html, value) do
    text = Parser.text(html)

    raise_match(matcher, text != value, fn
      :assert -> [left: text, right: value, expr: "#{inspect(text)} == #{inspect(value)}", message: "Comparison (using ==) failed in:"]
      :refute -> [expr: "#{inspect(text)} != #{inspect(value)}", message: "Comparison (using !=) failed in:"]
    end)
  end

  def assert_attributes(html, selector, attributes, sub_fn \\ nil) do
    html_tree = selector(:assert, html, selector)
    html_element = Parser.to_html(html_tree)

    attributes
    |> Enum.into(%{}, fn {k, v} -> {to_string(k), v} end)
    |> Enum.each(fn
      {attribute, nil} ->
        value = Parser.attribute(html_tree, attribute)
        raise_match(:assert, value, fn _ ->
          "Attribute `#{attribute}` matched, but should haven't matched.\n\n#{html_element}."
        end)

      {"class", value} ->
        case Parser.attribute(html_tree, "class") do
          nil ->
            assert_error("Attribute `class` not found.\n\n#{html_element}")

          css_class ->
            for check_class <- String.split(value, " ") do
              raise_match(:assert, !String.contains?(css_class, check_class), fn _ ->
                "Class `#{check_class}` not found in `#{css_class}` class attribute\n\n#{html_element}"
              end)
            end
        end

      {"text", value} ->
        escaped_value = value |> HTML.html_escape()
        text = Selector.attribute(html_tree, "text")

        raise_match(:assert, text == escaped_value, fn _ ->
          [
            message: "Comparison `text` attribute failed.\n\n#{html_element}.",
            expr: "#{inspect(text)} == #{inspect(escaped_value)}",
            left: value,
            right: text
          ]
        end)

      {attribute, value} ->
        text = to_string(value)
        value = Selector.attribute(html_tree, attribute)

        raise_match(:assert, text != value, fn _ ->
          [
            message: "Comparison `#{attribute}` attribute failed.\n\n#{html_element}.",
            expr: "#{inspect(text)} == #{inspect(value)}",
            left: value,
            right: text
          ]
        end)
    end)

    if sub_fn do
      sub_fn.(Parser.to_html(html_tree))
    end
  end

  defp raise_match(check, condition, message_fn) do
    cond do
      check == :assert -> condition
      check == :refute -> !condition
      true -> false
    end
    |> if do
      assert_error(message_fn.(check))
    end
  end

  defp assert_error(message_or_args) do
    args = (is_list(message_or_args) && message_or_args) || [message: message_or_args]

    raise ExUnit.AssertionError, args
  end
end

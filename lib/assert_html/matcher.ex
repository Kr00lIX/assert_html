defmodule AssertHTML.Matcher do
  @moduledoc false

  alias AssertHTML
  alias AssertHTML.{Parser, Selector}

  @compile {:inline, assert_error: 1, raise_match: 2, raise_match: 3}

  @typep assert_or_refute :: :assert | :refute

  @spec selector(assert_or_refute, AssertHTML.html(), AssertHTML.css_selector()) :: no_return()
  def selector(matcher, html, selector) do
    doc = Parser.find(html, selector)

    raise_match(matcher, doc == [], fn
      :assert -> "Element `#{selector}` not found.\n\n\t#{html}\n"
      :refute -> "Selector `#{selector}` succeeded, but should have failed.\n\n\t#{html}\n"
    end)

    doc
  end

  def contain(matcher, html, value) do
    str_value = to_string(value)

    raise_match(matcher, !String.contains?(html, str_value), fn
      :assert -> "Value `#{value}` not found.\n\n\t#{html}\n"
      :refute -> "Value `#{value}` found, but shouldn't.\n\n\t#{html}\n"
    end)
  end

  def text(matcher, html, selector, value) do
    doc = Parser.find(html, selector)

    # ignore if element not found for :refute
    if matcher == :assert do
      raise_match(matcher, doc == [], fn _matcher ->
        "Element `#{selector}` not found.\n\n\t#{html}\n"
      end)
    end

    selected_html = Parser.to_html(doc)
    text(matcher, selected_html, value)
  end

  def text(matcher, html_element, %Regex{} = value) do
    text = Parser.text(html_element)

    raise_match(matcher, !Regex.match?(value, text), fn
      :assert -> [message: "Match failed #{inspect(value)} in `#{text}`.\n\n\t#{html_element}.", left: value, right: html_element]
      :refute -> [message: "Text matched, but should haven't matched.\n\n\t#{html_element}.", left: value, right: html_element]
    end)
  end

  def text(matcher, html, value) do
    text = Parser.text(html)

    raise_match(matcher, text != value, fn
      :assert -> [left: text, right: value, message: "Comparison (using ==) failed in:"]
      :refute -> [left: text, right: value, message: "Comparison (using !=) failed in:"]
    end)
  end

  def assert_attributes(html, selector, attributes, sub_fn \\ nil) do
    html_tree = selector(:assert, html, selector)
    html_element = Parser.to_html(html_tree)

    attributes
    |> Enum.into(%{}, fn {k, v} -> {to_string(k), v} end)
    |> Enum.each(fn {attr, check_value} ->
      attr_value = Selector.attribute(html_tree, attr)

      case {attr, check_value, attr_value} do
        {_attr, nil, attr_value} ->
          raise_match(attr_value != nil, fn _ -> "Attribute `#{attr}` matched, but should haven't matched.\n\n\t#{html_element}.\n" end)

        {attr, _check_value, nil} ->
          assert_error("Attribute `#{attr}` not found.\n\n\t#{html_element}\n")

        {"class", check_value, attr_value} ->
          for check_class <- String.split(check_value, " ") do
            raise_match(!String.contains?(attr_value, check_class), fn _ ->
              "Class `#{check_class}` not found in `#{attr_value}` class attribute\n\n\t#{html_element}\n"
            end)
          end

        {attr, %Regex{} = check_value, attr_value} ->
          raise_match(!Regex.match?(check_value, attr_value), fn _ ->
            [
              message: "Comparison `#{attr}` attribute failed.\n\n\t#{html_element}.\n",
              left: check_value,
              right: attr_value
            ]
          end)

        {attribute, check_value, attr_value} ->
          str_check_value = to_string(check_value)

          raise_match(str_check_value != attr_value, fn _ ->
            [
              message: "Comparison `#{attribute}` attribute failed.\n\n\t#{html_element}.\n",
              left: str_check_value,
              right: attr_value
            ]
          end)
      end
    end)

    if sub_fn do
      sub_fn.(Parser.to_html(html_tree))
    end
  end

  defp raise_match(check \\ :assert, condition, message_fn) when check in [:assert, :refute] do
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

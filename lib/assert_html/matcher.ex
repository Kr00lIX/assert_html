defmodule AssertHTML.Matcher do
  @moduledoc false

  alias AssertHTML
  alias AssertHTML.{Selector}

  @compile {:inline, raise_match: 3}

  @typep assert_or_refute :: :assert | :refute

  @spec selector(assert_or_refute, binary, binary()) :: nil | AssertHTML.html()
  def selector(matcher, html, selector) when is_binary(html) and is_binary(selector) do
    sub_html = Selector.find(html, selector)

    raise_match(matcher, sub_html == nil, fn
      :assert -> "Element `#{selector}` not found.\n\n\t#{html}\n"
      :refute -> "Selector `#{selector}` succeeded, but should have failed.\n\n\t#{html}\n"
    end)

    sub_html
  end

  @spec attributes(assert_or_refute, AssertHTML.html(), AssertHTML.attributes()) :: any()
  def attributes(matcher, html, attributes) when is_list(attributes) do
    attributes
    |> Enum.into(%{}, fn {k, v} -> {to_string(k), v} end)
    |> Enum.each(fn {attribute, check_value} ->
      attr_value = Selector.attribute(html, attribute)
      match_attribute(matcher, attribute, check_value, attr_value, html)
    end)
  end

  @spec contain(assert_or_refute, binary(), Regex.t()) :: any()
  def contain(matcher, html, %Regex{} = value) when is_binary(html) do
    raise_match(matcher, !Regex.match?(value, html), fn
      :assert -> [message: "Value not matched.", left: html, right: value]
      :refute -> [message: "Value `#{inspect(value)}` matched, but shouldn't.", left: html, right: value]
    end)
  end

  @spec contain(assert_or_refute, AssertHTML.html(), AssertHTML.html()) :: any()
  def contain(matcher, html, value) when is_binary(html) and is_binary(value) do
    raise_match(matcher, !String.contains?(html, value), fn
      :assert -> [message: "Value not found.", left: html, right: value]
      :refute -> [message: "Value `#{inspect(value)}` found, but shouldn't.", left: html, right: value]
    end)
  end

  @spec match_attribute(assert_or_refute, AssertHTML.attribute_name, AssertHTML.value, binary() | nil, AssertHTML.html) :: no_return
  defp match_attribute(matcher, attribute, check_value, attr_value, html)

  # attribute should exists
  defp match_attribute(matcher, attribute, check_value, attr_value, html) when check_value in [nil, true, false] do
    raise_match(matcher, (if check_value, do: attr_value == nil, else: attr_value != nil), fn
      :assert ->
        if check_value,
        do: "Attribute `#{attribute}` should exists.\n\n\t#{html}\n",
        else: "Attribute `#{attribute}` shouldn't exists.\n\n\t#{html}\n"

      :refute ->
        if check_value,
        do: "Attribute `#{attribute}` shouldn't exists.\n\n\t#{html}\n",
        else: "Attribute `#{attribute}` should exists.\n\n\t#{html}\n"
    end)
  end

  # attribute should not exists
  defp match_attribute(matcher, attribute, _check_value, nil = _attr_value, html) do
    raise_match(matcher, matcher == :assert, fn
      _ -> "Attribute `#{attribute}` not found.\n\n\t#{html}\n"
    end)
  end

  defp match_attribute(matcher, attribute, %Regex{} = check_value, attr_value, html) do
    raise_match(matcher, !Regex.match?(check_value, attr_value), fn _ ->
      [
        message: "Matching `#{attribute}` attribute failed.\n\n\t#{html}.\n",
        left: check_value,
        right: attr_value
      ]
    end)
  end

  defp match_attribute(matcher, "class", check_value, attr_value, html) do
    for check_class <- String.split(to_string(check_value), " ") do
      raise_match(matcher, !String.contains?(attr_value, check_class), fn
        :assert -> "Class `#{check_class}` not found in `#{attr_value}` class attribute\n\n\t#{html}\n"
        :refute -> "Class `#{check_class}` found in `#{attr_value}` class attribute\n\n\t#{html}\n"
      end)
    end
  end

  defp match_attribute(matcher, attribute, check_value, attr_value, html) do
    str_check_value = to_string(check_value)

    raise_match(matcher, str_check_value != attr_value, fn _ ->
      [
        message: "Comparison `#{attribute}` attribute failed.\n\n\t#{html}.\n",
        left: str_check_value,
        right: attr_value
      ]
    end)
  end

  defp raise_match(check, condition, message_fn) when check in [:assert, :refute] do
    cond do
      check == :assert -> condition
      check == :refute -> !condition
      true -> false
    end
    |> if do
      message_or_args = message_fn.(check)
      args = (is_list(message_or_args) && message_or_args) || [message: message_or_args]
      raise ExUnit.AssertionError, args
    end
  end
end

defmodule AssertHTML.Matcher do
  @moduledoc false

  alias AssertHTML
  alias AssertHTML.{Parser, Selector}

  @compile {:inline, raise_match: 3}

  @typep assert_or_refute :: :assert | :refute

  ## ----------------------------------------------------
  ## Collection

  @doc """
  Gets html by selector and raise error if it doesn't exists

  # Options
  * `once` - only one element
  * `skip_refute` - do not raise error if element exists for refute
  """
  @spec selector(AssertHTML.context(), binary(), list()) :: AssertHTML.html()
  def selector({matcher, html}, selector, options \\ []) when is_binary(html) and is_binary(selector) do
    docs = Parser.find(html, selector)

    # found more than one element
    if options[:once] && length(docs) > 1 do
      raise_match(matcher, matcher == :assert, fn
        :assert ->
          "Found more than one element by `#{selector}` selector.\nPlease use `#{selector}:first-child`, `#{selector}:nth-child(n)` for limiting search area.\n\n\t#{html}\n"

        :refute ->
          "Selector `#{selector}` succeeded, but should have failed.\n\n\t#{html}\n"
      end)
    end

    raise_match(matcher, docs == [], fn
      :assert ->
        "Element `#{selector}` not found.\n\n\t#{html}\n"

      :refute ->
        if options[:skip_refute],
          do: nil,
          else: "Selector `#{selector}` succeeded, but should have failed.\n\n\t#{html}\n"
    end)

    Parser.to_html(docs)
  end

  @doc """
  Check count of elements on selector
  """
  @spec count(AssertHTML.context(), binary(), integer()) :: any()
  def count({matcher, html}, selector, check_value) do
    count_elements = Parser.count(html, selector)

    raise_match(matcher, count_elements != check_value, fn
      :assert ->
        [
          message: "Expected #{check_value} element(s). Got #{count_elements} element(s).",
          left: count_elements,
          right: check_value
        ]

      :refute ->
        [
          message: "Expected  different number of element(s), but received equal",
          left: count_elements,
          right: check_value
        ]
    end)
  end

  @doc """
  Check count of elements on selector
  """
  @spec min(AssertHTML.context(), binary(), integer()) :: any()
  def min({matcher, html}, selector, min_value) do
    count_elements = Parser.count(html, selector)

    raise_match(matcher, count_elements < min_value, fn
      :assert ->
        [
          message: "Expected at least #{min_value} element(s). Got #{count_elements} element(s).",
          left: count_elements,
          right: min_value
        ]

      :refute ->
        [
          message: "Expected at most #{min_value} element(s). Got #{count_elements} element(s).",
          left: count_elements,
          right: min_value
        ]
    end)
  end

  @doc """
  Check count of elements on selector
  """
  @spec max(AssertHTML.context(), binary(), integer()) :: any()
  def max({matcher, html}, selector, max_value) do
    count_elements = Parser.count(html, selector)

    raise_match(matcher, count_elements > max_value, fn
      :assert ->
        [
          message: "Expected at most #{max_value} element(s). Got #{count_elements} element(s).",
          left: count_elements,
          right: max_value
        ]

      :refute ->
        [
          message: "Expected at least #{max_value} element(s). Got #{count_elements} element(s).",
          left: count_elements,
          right: max_value
        ]
    end)
  end

  ## ----------------------------------------------------
  ## Element

  @spec attributes(AssertHTML.context(), AssertHTML.attributes()) :: any()
  def attributes({matcher, html}, attributes) when is_list(attributes) do
    attributes
    |> Enum.into(%{}, fn {k, v} -> {to_string(k), v} end)
    |> Enum.each(fn {attribute, check_value} ->
      attr_value = Selector.attribute(html, attribute)
      match_attribute(matcher, attribute, check_value, attr_value, html)
    end)
  end

  @spec contain(AssertHTML.context(), Regex.t()) :: any()
  def contain({matcher, html}, %Regex{} = value) when is_binary(html) do
    raise_match(matcher, !Regex.match?(value, html), fn
      :assert ->
        [
          message: "Value not matched.",
          left: value,
          right: html,
          expr: "assert_html(#{inspect(value)})"
        ]

      :refute ->
        [
          message: "Value `#{inspect(value)}` matched, but shouldn't.",
          left: value,
          right: html,
          expr: "assert_html(#{inspect(value)})"
        ]
    end)
  end

  @spec contain(AssertHTML.context(), AssertHTML.html()) :: any()
  def contain({matcher, html}, value) when is_binary(html) and is_binary(value) do
    raise_match(matcher, !String.contains?(html, value), fn
      :assert ->
        [
          message: "Value not found.",
          left: value,
          right: html,
          expr: "assert_html(#{inspect(value)})"
        ]

      :refute ->
        [
          message: "Value `#{inspect(value)}` found, but shouldn't.",
          left: value,
          right: html,
          expr: "assert_html(#{inspect(value)})"
        ]
    end)
  end

  @spec match_attribute(
          assert_or_refute,
          AssertHTML.attribute_name(),
          AssertHTML.value(),
          binary() | nil,
          AssertHTML.html()
        ) :: no_return
  defp match_attribute(matcher, attribute, check_value, attr_value, html)

  # attribute should exists
  defp match_attribute(matcher, attribute, check_value, attr_value, html) when check_value in [nil, true, false] do
    raise_match(matcher, if(check_value, do: attr_value == nil, else: attr_value != nil), fn
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

      if message_or_args do
        args = (is_list(message_or_args) && message_or_args) || [message: message_or_args]
        raise ExUnit.AssertionError, args
      end
    end
  end
end

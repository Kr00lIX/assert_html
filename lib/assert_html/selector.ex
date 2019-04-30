defmodule AssertHTML.Selector do
  @moduledoc false

  alias AssertHTML.Parser

  @spec find(AssertHTML.html(), AssertHTML.css_selector()) :: AssertHTML.html() | nil
  def find(_html, nil) do
    nil
  end
  def find(html, css_selector) do
    html
    |> Parser.find(css_selector)
    |> Parser.to_html()
    |> case do
      "" -> nil
      other when is_binary(other) -> other
    end
  end

  @spec attribute(AssertHTML.html(), atom() | binary()) :: nil | binary()
  def attribute(html, attribute_name) when is_binary(html) and is_atom(attribute_name) do
    attribute(html, to_string(attribute_name))
  end

  def attribute(html, "text") when is_binary(html) do
    text(html)
  end

  def attribute(html, attribute_name) when is_binary(html) and is_binary(attribute_name) do
    Parser.attribute(html, attribute_name)
  end

  @doc ~S"""
  Gets text from HTML element
  """
  @spec text(AssertHTML.html()) :: binary()
  def text(html) when is_binary(html) do
    html
    |> Parser.text()
    |> String.trim()
  end
end

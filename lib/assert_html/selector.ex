defmodule AssertHTML.Selector do
  @moduledoc false

  alias AssertHTML.Parser

  @spec find(AssertHTML.html(), AssertHTML.css_selector()) :: AssertHTML.html() | nil
  def find(html, css_selector) do
    html
    |> Parser.find(css_selector)
    |> Parser.to_html()
    |> case do
      "" -> nil
      other when is_binary(other) -> other
    end
  end

  @spec attribute(AssertHTML.html(), AssertHTML.css_selector(), AssertHTML.attribute_name()) :: AssertHTML.html()
  def attribute(html, css_selector, "text") do
    text(html, css_selector)
  end

  def attribute(html, css_selector, name) do
    Parser.attribute(html, css_selector, name)
  end

  def attribute(html, "text") do
    text(html)
  end

  def attribute(html, name) do
    html
    |> Parser.attribute(name)
  end

  @doc ~S"""
  Gets text from HTML element
  """
  @spec text(AssertHTML.html(), AssertHTML.css_selector()) :: String.t()
  def text(html, css_selector) do
    html
    |> Parser.find(css_selector)
    |> text()
  end

  @doc ~S"""
  Gets text from HTML element
  """
  @spec text(AssertHTML.html()) :: String.t()
  def text(html) do
    html
    |> Parser.text()
    |> String.trim()
  end
end

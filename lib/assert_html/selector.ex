defmodule AssertHtml.Selector do
  @moduledoc false

  alias AssertHtml.Parser

  @spec find(AssertHtml.html(), AssertHtml.css_selector()) :: AssertHtml.html() | nil
  def find(html, css_selector) do
    html
    |> Parser.find(css_selector)
    |> Parser.to_html()
    |> case do
      "" -> nil
      other when is_binary(other) -> other
    end
  end

  @spec attribute(AssertHtml.html(), AssertHtml.css_selector(), AssertHtml.attribute_name()) :: AssertHtml.html()
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
  @spec text(AssertHtml.html(), AssertHtml.css_selector()) :: String.t()
  def text(html, css_selector) do
    html
    |> Parser.find(css_selector)
    |> text()
  end

  @doc ~S"""
  Gets text from HTML element
  """
  @spec text(AssertHtml.html()) :: String.t()
  def text(html) do
    html
    |> Parser.text()
    |> String.trim()
  end
end

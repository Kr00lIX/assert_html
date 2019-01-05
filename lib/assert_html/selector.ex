defmodule AssertHtml.Selector do
  @moduledoc false

  alias AssertHtml.Parser

  @spec find(AssertHtml.html(), AssertHtml.css_selector()) :: nil | AssertHtml.html()
  def find(html, css_selector) do
    Parser.find(html, css_selector)
    |> Parser.to_html()
    |> case do
      "" -> nil
      other -> other
    end
  end

  def attribute(html, css_selector, name) do
    Parser.attribute(html, css_selector, name)
  end

  def attribute(html, name) do
    Parser.attribute(html, name)
  end

  def text(html, css_selector) do
    Parser.find(html, css_selector) |> Parser.text() |> String.trim()
  end
end

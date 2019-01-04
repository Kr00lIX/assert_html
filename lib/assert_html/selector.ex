defmodule AssertHtml.Selector do

  alias AssertHtml.Parser

  def find(html, selector) do
    Parser.find(html, selector) |> Parser.to_html()
  end

  def attribute(html, selector, name) do
    Parser.attribute(html, selector, name)
  end

  def attribute(html, name) do
    Parser.attribute(html, name)
  end

  def text(html, selector) do
    Parser.find(html, selector) |> Parser.text() |> String.trim()
  end

end

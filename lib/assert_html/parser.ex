defmodule AssertHtml.Parser do
  @moduledoc false

  @typep html_element_tuple :: any()

  @spec find(AssertHtml.html(), AssertHtml.css_selector()) :: html_element_tuple
  def find(html, selector) do
    Floki.find(html, selector)
  end

  def attribute(html, selector, name) do
    case Floki.attribute(html, selector, name) do
      [value] -> value
      _ -> nil
    end
  end

  @doc """
  Returns attribute value for a given selector.
  """
  def attribute(html, name) do
    case Floki.attribute(html, name) do
      [value] -> value
      _ -> nil
    end
  end

  def text(html_element_tuple) do
    Floki.text(html_element_tuple)
  end

  def to_html(html_element_tuple) do
    Floki.raw_html(html_element_tuple)
  end
end

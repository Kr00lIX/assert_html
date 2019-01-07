defmodule AssertHtml.Parser do
  @moduledoc false

  @typep html_element_tuple :: binary() | [any()] | tuple()
  @type html_tree :: html_element_tuple

  @doc """
  Find node

  ## Example

  Assuming that you have the following HTML:

  ```html
  <!doctype html>
  <html>
  <body>
    <section id="content">
      <p class="headline">Floki</p>
      <a href="http://github.com/philss/floki">Github page</a>
      <span data-model="user">philss</span>
    </section>
  </body>
  </html>
  ```

  Examples of queries that you can perform:

      find(html, "#content")
      find(html, ".headline")
      find(html, "a")
      find(html, "[data-model=user]")
      find(html, "#content a")
      find(html, ".headline, a")
      Each HTML node is represented by a tuple like:

      {tag_name, attributes, children_nodes}
  """
  @spec find(html_tree, AssertHtml.css_selector()) :: html_tree
  def find(html, selector) do
    Floki.find(html, selector)
  end

  @spec attribute(html_tree, AssertHtml.css_selector(), String.t()) :: String.t() | nil
  def attribute(html, selector, name) do
    case Floki.attribute(html, selector, name) do
      [value] -> value
      _ -> nil
    end
  end

  @doc """
  Returns attribute value for a given selector.
  """
  @spec attribute(html_tree, String.t()) :: String.t() | nil
  def attribute(html, name) do
    case Floki.attribute(html, name) do
      [value] -> value
      _ -> nil
    end
  end

  @spec text(html_tree) :: String.t()
  def text(html_element_tuple) do
    Floki.text(html_element_tuple)
  end

  @spec to_html(html_tree) :: String.t()
  def to_html(html_element_tuple) do
    Floki.raw_html(html_element_tuple)
  end
end

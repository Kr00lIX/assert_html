defmodule AssertHTML.Parser do
  @moduledoc false

  @typep html_element_tuple :: binary() | [any()] | tuple()
  @typep html_tree :: html_element_tuple

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
  @spec find(AssertHTML.html(), AssertHTML.css_selector()) :: html_tree
  def find(html, selector) do
    Floki.find(html, selector)
  end

  @spec find(AssertHTML.html(), AssertHTML.css_selector()) :: integer()
  def count(html, selector) do
    find(html, selector) |> Enum.count()
  end

  @doc """
  Returns attribute value for a given selector.
  """
  @spec attribute(AssertHTML.html(), String.t()) :: String.t() | nil
  def attribute(html, name) do
    case Floki.attribute(html, name) do
      [value] -> value
      _ -> nil
    end
  end

  @spec text(AssertHTML.html()) :: String.t()
  def text(html_element_tuple) do
    Floki.text(html_element_tuple, deep: false)
  end

  @spec to_html(html_tree) :: String.t()
  def to_html(html_element_tuple) do
    Floki.raw_html(html_element_tuple)
  end
end

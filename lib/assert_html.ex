defmodule AssertHtml do
  @moduledoc """
  Documentation for AssertHtml.
  """

  alias AssertHtml.{Matcher, Selector}

  @typedoc ~S"""
  CSS selector

  ## Supported selectors

  | Pattern         | Description                  |
  |-----------------|------------------------------|
  | *               | any element                  |
  | E               | an element of type `E`       |
  | E[foo]          | an `E` element with a "foo" attribute |
  | E[foo="bar"]    | an E element whose "foo" attribute value is exactly equal to "bar" |
  | E[foo~="bar"]   | an E element whose "foo" attribute value is a list of whitespace-separated values, one of which is exactly equal to "bar" |
  | E[foo^="bar"]   | an E element whose "foo" attribute value begins exactly with the string "bar" |
  | E[foo$="bar"]   | an E element whose "foo" attribute value ends exactly with the string "bar" |
  | E[foo*="bar"]   | an E element whose "foo" attribute value contains the substring "bar" |
  | E[foo\|="en"]    | an E element whose "foo" attribute has a hyphen-separated list of values beginning (from the left) with "en" |
  | E:nth-child(n)  | an E element, the n-th child of its parent |
  | E:first-child   | an E element, first child of its parent |
  | E:last-child   | an E element, last child of its parent |
  | E:nth-of-type(n)  | an E element, the n-th child of its type among its siblings |
  | E:first-of-type   | an E element, first child of its type among its siblings |
  | E:last-of-type   | an E element, last child of its type among its siblings |
  | E.warning       | an E element whose class is "warning" |
  | E#myid          | an E element with ID equal to "myid" |
  | E:not(s)        | an E element that does not match simple selector s |
  | E F             | an F element descendant of an E element |
  | E > F           | an F element child of an E element |
  | E + F           | an F element immediately preceded by an E element |
  | E ~ F           | an F element preceded by an E element |

  """
  @opaque css_selector :: String.t()

  @opaque html :: String.t()

  @type attributes :: []

  @typedoc """
  HTML element attribute name
  """
  @type attribute_name :: String.t() | atom()

  @typep value :: String.t()

  @doc ~S"""
  Returns part of HTML by CSS selector

  ## Examples
      iex> html = ~S{ <p><div class="foo"><h1>Header</h1</div></p>  }
      ...> html_selector(html, "p .foo")
      ~S{<div class="foo"><h1>Header</h1></div>}

      iex> html = ~S{ <p><div class="foo"><h1>Header</h1</div></p>  }
      ...> html_selector(html, "h1")
      "<h1>Header</h1>"
  """
  @spec html_selector(html, css_selector) :: html | nil
  def html_selector(html, css_selector) do
    Selector.find(html, css_selector)
  end

  @doc ~S"""
  Gets an element’s attribute value

  ```elixir
  iex> html_attribute(~S{<div class="foo bar">text</div>}, "class")
  "foo bar"

  iex> html_attribute(~S{<div>text</div>}, "id")
  nil
  ```
  """
  @spec html_attribute(html, attribute_name) :: value | nil
  def html_attribute(html, attribute_name) do
    Selector.attribute(html, attribute_name)
  end

  @doc """
  Gets an element’s attribute value via CSS selector

  ```elixir
  iex> html = ~S{<div class="foo bar"></div><div class="zoo bar"></div>}
  ...> html_attribute(html, ".zoo", "class")
  "zoo bar"
  ```
  """
  @spec html_attribute(html, css_selector, attribute_name) :: value | nil
  def html_attribute(html, css_selector, name) do
    Selector.attribute(html, css_selector, name)
  end

  @spec html_text(html, css_selector) :: String.t() | nil
  def html_text(html, css_selector) do
    Selector.text(html, css_selector)
  end

  @doc """
  Asserts an element in HTML
  """
  @spec assert_html_selector(html, css_selector) :: html | no_return
  def assert_html_selector(html, css_selector) do
    Matcher.selector(:assert, html, css_selector)
    html
  end

  @spec assert_html_text(html, value) :: html | no_return
  def assert_html_text(html, value) do
    Matcher.match_text(:assert, html, value)
    html
  end

  @spec assert_html_text(html, css_selector, value) :: html | no_return
  def assert_html_text(html, css_selector, value) do
    Matcher.match_text(:assert, html, css_selector, value)
    html
  end

  @spec refute_html_text(html, css_selector, value) :: html | no_return
  def refute_html_text(html, css_selector, value) do
    Matcher.match_text(:refute, html, css_selector, value)
    html
  end

  @spec assert_match_html_text(html, value) :: html | no_return
  def assert_match_html_text(html, value) do
    Matcher.match_text(:assert, html, value)
    html
  end

  @spec refute_match_html_text(html, css_selector, value) :: html | no_return
  def refute_match_html_text(html, css_selector, value) do
    Matcher.match_text(:refute, css_selector, value)
    html
  end

  @spec refute_html_selector(html, css_selector) :: html | no_return
  def refute_html_selector(html, css_selector) do
    Matcher.selector(:refute, html, css_selector)
    html
  end

  @spec assert_html_attributes(html, css_selector, attributes, fun | nil) :: html | no_return
  def assert_html_attributes(html, css_selector, attributes, subl_html_fn \\ nil) do
    Matcher.assert_attributes(html, css_selector, attributes, subl_html_fn)
    html
  end

  @spec refute_html_text(html, value) :: html | no_return
  def refute_html_text(html, value) do
    Matcher.match_text(:refute, html, value)
    html
  end
end

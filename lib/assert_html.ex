defmodule AssertHTML do
  @moduledoc """
  AssertHTML is an Elixir library for parsing and extracting data from HTML and XML with CSS.
  """

  alias AssertHTML.{Matcher, Selector}

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

  # use macro definition
  defmacro __using__(_opts) do
    quote location: :keep do
      import AssertHTML.DSL
      import AssertHTML, except: [
          assert_html: 2, assert_html: 3, assert_html: 4,
          refute_html: 2, refute_html: 3, refute_html: 4
        ]
    end
  end

  @doc """
  """
  def assert_html(html, css_selector) when is_binary(html) and is_binary(css_selector) do
    html(:assert, html, css_selector)
  end
  def assert_html(html, attributes) when is_binary(html) and is_list(attributes) do
    html(:assert, html, nil, attributes)
  end
  def assert_html(html, inside_fn) when is_binary(html) and is_function(inside_fn) do
    html(:assert, html, nil, nil, inside_fn)
  end

  def assert_html(html, attributes, inside_fn) when is_binary(html) and is_list(attributes) and is_function(inside_fn) do
    html(:assert, html, nil, attributes, inside_fn)
  end
  def assert_html(html, css_selector, inside_fn) when is_binary(html) and is_binary(css_selector) and is_function(inside_fn) do
    html(:assert, html, css_selector, nil, inside_fn)
  end
  def assert_html(html, css_selector, attributes, inside_fn \\ nil) do
    html(:assert, html, css_selector, attributes, inside_fn)
  end

  def refute_html(html, css_selector) when is_binary(html) and is_binary(css_selector) do
    html(:refute, html, css_selector)
  end
  def refute_html(html, attributes) when is_binary(html) and is_list(attributes) do
    html(:refute, html, nil, attributes)
  end
  def refute_html(html, inside_fn) when is_binary(html) and is_function(inside_fn) do
    html(:refute, html, nil, nil, inside_fn)
  end
  def refute_html(html, attributes, inside_fn) when is_binary(html) and is_list(attributes) and is_function(inside_fn) do
    html(:refute, html, nil, attributes, inside_fn)
  end
  def refute_html(html, css_selector, inside_fn) when is_binary(html) and is_binary(css_selector) and is_function(inside_fn) do
    html(:refute, html, css_selector, nil, inside_fn)
  end
  def refute_html(html, css_selector, attributes, inside_fn \\ nil) when is_binary(html) and is_binary(css_selector) do
    html(:refute, html, css_selector, attributes, inside_fn)
  end

  defp html(matcher, context, css_selector, attributes \\ nil, inside_fn \\ nil) do
    # [matcher: matcher, context: context, css_selector: css_selector, attributes: attributes, inside_fn: inside_fn] |> IO.inspect(label: "html")

    sub_context =
      if css_selector != nil do
        Matcher.selector(matcher, context, css_selector)
      else
        context
      end

    if attributes do
      # check attributes sub_context
      Matcher.attributes(sub_context, attributes)
    end

    # call inside block
    if inside_fn do
      inside_fn.(sub_context)
    end
    context
  end

end

defmodule AssertHTML do
  @moduledoc ~s"""
  AssertHTML is an Elixir library for parsing and extracting data from HTML and XML with CSS.
  """

  alias AssertHTML.{Matcher, Selector, Debug}

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
  @type value :: nil | String.t | Regex.t

  # @typep value :: String.t()

  # use macro definition
  defmacro __using__(_opts) do
    quote location: :keep do
      import AssertHTML.DSL

      import AssertHTML,
        except: [
          assert_html: 2,
          assert_html: 3,
          assert_html: 4,
          refute_html: 2,
          refute_html: 3,
          refute_html: 4
        ]
    end
  end

  # defguardp is_regex(value) when is_map(value) and :erlang.is_map_key(value, :__struct__) and :erlang.is_map_key(value, :source) and :erlang.is_map_key(value, :re_pattern)
  # defguardp is_contains(value) when is_binary(value) or is_regex(value)

  ### assert

  @doc ~S"""
  Asserts an attributes in HTML element


  ## assert attributes

  ### Attribute names
  - `text` – asserts an text element in HTML
  - `:match` - asserts containing value in html

      iex> html = ~S{<div class="foo bar"></div><div class="zoo bar"></div>}
      ...> assert_html(html, ".zoo", class: "bar zoo")
      ~S{<div class="foo bar"></div><div class="zoo bar"></div>}

      # check if `id` not exsists
      iex> assert_html(~S{<div>text</div>}, id: nil)
      "<div>text</div>"


  #### Examples check :text

  Asserts an text element in HTML

      iex> html = ~S{<h1 class="title">Header</h1>}
      ...> assert_html(html, text: "Header")
      ~S{<h1 class="title">Header</h1>}

      iex> html = ~S{<div class="container">   <h1 class="title">Header</h1>   </div>}
      ...> assert_html(html, ".title", text: "Header")
      ~S{<div class="container">   <h1 class="title">Header</h1>   </div>}


      iex> html = ~S{<h1 class="title">Header</h1>}
      ...> try do
      ...>   assert_html(html, text: "HEADER")
      ...> rescue
      ...>   e in ExUnit.AssertionError -> e
      ...> end
      %ExUnit.AssertionError{
        left: "HEADER",
        right: "Header",
        message: "Comparison `text` attribute failed.\n\n\t<h1 class=\"title\">Header</h1>.\n"
      }

      iex> html = ~S{<div class="foo">Some &amp; text</div>}
      ...> assert_html(html, text: "Some & text")
      ~S{<div class="foo">Some &amp; text</div>}


  ## Selector

      # assert_html(html, "css selector")

      iex> html = ~S{<p><div class="foo"><h1>Header</h1></div></p>}
      ...> assert_html(html, "p .foo h1")
      ~S{<p><div class="foo"><h1>Header</h1></div></p>}

      iex> html = ~S{<p><div class="foo"><h1>Header</h1></div></p>}
      ...> assert_html(html, "h1")
      ~S{<p><div class="foo"><h1>Header</h1></div></p>}



  ## Match elements in HTML
      assert_html(html, ~r{<p>Hello</p>})
      assert_html(html, match: ~r{<p>Hello</p>})
      assert_html(html, match: "<p>Hello</p>")

        # Asserts an text element in HTML

  ### Examples

      iex> html = ~S{<div class="container">   <h1 class="title">Hello World</h1>   </div>}
      ...> assert_html(html, "h1", "Hello World") == html
      true

      iex> html = ~S{<div class="container">   <h1 class="title">Hello World</h1>   </div>}
      ...> assert_html(html, ".title", ~r{World})
      ~S{<div class="container">   <h1 class="title">Hello World</h1>   </div>}

  ## assert elements in selector
      assert_html(html, ".container table", ~r{<p>Hello</p>})





  ### text or html exists
  assert_html(html, ~r{<p>Hello</p>})
  """
  def assert_html(html, %Regex{} = value) do
    html(:assert, html, nil, [match: value])
  end

  def assert_html(html, block_fn) when is_binary(html) and is_function(block_fn) do
    html(:assert, html, nil, nil, block_fn)
  end

  def assert_html(html, css_selector) when is_binary(html) and is_binary(css_selector) do
    html(:assert, html, css_selector)
  end

  def assert_html(html, attributes) when is_binary(html) and is_list(attributes) do
    html(:assert, html, nil, attributes)
  end

  def assert_html(html, %Regex{} = value, block_fn) when is_binary(html) and is_function(block_fn) do
    html(:assert, html, nil, [match: value], block_fn)
  end

  def assert_html(html, attributes, block_fn) when is_binary(html) and is_list(attributes) and is_function(block_fn) do
    html(:assert, html, nil, attributes, block_fn)
  end

  def assert_html(html, css_selector, block_fn) when is_binary(html) and is_binary(css_selector) and is_function(block_fn) do
    html(:assert, html, css_selector, nil, block_fn)
  end

  def assert_html(html, css_selector, attributes, block_fn \\ nil)

  def assert_html(html, css_selector, %Regex{}=value, block_fn) when is_binary(html) and is_binary(css_selector) do
    html(:assert, html, css_selector, [match: value], block_fn)
  end
  def assert_html(html, css_selector, value, block_fn) when is_binary(html) and is_binary(css_selector) and is_binary(value) do
    html(:assert, html, css_selector, [match: value], block_fn)
  end

  def assert_html(html, css_selector, value, block_fn)  when is_binary(html) and is_binary(css_selector) and is_binary(value) do
    html(:assert, html, css_selector, [match: value], block_fn)
  end

  def assert_html(html, css_selector, attributes, block_fn) do
    html(:assert, html, css_selector, attributes, block_fn)
  end

  ###################################
  ### refute

  @doc ~S"""

  """
  # def refute_html(html, css_selector, attributes, block_fn \\ nil)
  def refute_html(html, %Regex{} = value) do
    html(:refute, html, nil, [match: value])
  end

  def refute_html(html, block_fn) when is_binary(html) and is_function(block_fn) do
    block_fn.(html)
    html
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

  def refute_html(html, %Regex{} = value, block_fn) when is_binary(html) and is_function(block_fn) do
    html(:refute, html, nil, [match: value], block_fn)
  end

  def refute_html(html, attributes, block_fn) when is_binary(html) and is_list(attributes) and is_function(block_fn) do
    html(:refute, html, nil, attributes, block_fn)
  end

  def refute_html(html, css_selector, block_fn) when is_binary(html) and is_binary(css_selector) and is_function(block_fn) do
    html(:refute, html, css_selector, nil, block_fn)
  end

  def refute_html(html, css_selector, attributes, block_fn \\ nil)

  def refute_html(html, css_selector, %Regex{}=value, block_fn) do
    html(:refute, html, css_selector, [match: value], block_fn)
  end
  def refute_html(html, css_selector, value, block_fn) when is_binary(html) and is_binary(css_selector) and is_binary(value) do
    html(:refute, html, css_selector, [match: value], block_fn)
  end
  def refute_html(html, css_selector, attributes, block_fn) do
    html(:refute, html, css_selector, attributes, block_fn)
  end

  defp html(matcher, context, css_selector, attributes \\ nil, block_fn \\ nil)
    when matcher in [:assert, :refute]
        and is_binary(context)
        and (is_binary(css_selector) or is_nil(css_selector))
        and (is_list(attributes) or is_nil(attributes))
        and (is_function(block_fn) or is_nil(block_fn))
  do
    Debug.log "call .html with arguments: #{inspect binding()}"
    attributes = is_list(attributes) && attributes || []
    sub_context = get_context(%{matcher: matcher, context: context, css_selector: css_selector, attributes: attributes})

    {contain_value, attributes} = Keyword.pop(attributes, :match)

    # check :match
    contain_value && Matcher.contain(matcher, sub_context, contain_value)

    if attributes != [] do
      Matcher.attributes(sub_context, attributes)
    end

    # call inside block
    if block_fn do
      block_fn.(sub_context)
    end

    context
  end

  defp get_context(%{context: context, css_selector: nil}) do
    context
  end
  defp get_context(%{matcher: :refute, attributes: attributes, context: context, css_selector: css_selector}) when attributes != [] do
    Selector.find(context, css_selector)
  end
  defp get_context(%{matcher: matcher, context: context, css_selector: css_selector}) do
    Matcher.selector(matcher, context, css_selector)
  end
end

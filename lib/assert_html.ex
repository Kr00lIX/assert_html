defmodule AssertHTML do
  @moduledoc ~s"""
  AssertHTML provides ExUnit assert helpers for testing rendered HTML using CSS selectors.

  ## Usage in Phoenix Controller and Integration Test

  Given the `html_response(conn, 200)` returns:

  ```html
  <!DOCTYPE html>
  <html>
    <head>
      <title>PAGE TITLE</title>
    </head>
    <body>
      <a href="/signup">Sign up</a>
      <a href="/help">Help</a>
    </body>
  </html>
  ```

  An example controller test could be:

  ```elixir
  defmodule YourAppWeb.PageControllerTest do
    use YourAppWeb.ConnCase, async: true

    test "should get index", %{conn: conn} do
      resp_conn = conn
      |> get(Routes.page_path(conn, :index))

      html_response(conn, 200)
      # Asserts that the page title is "PAGE TITLE"
      |> assert_html("title", "PAGE TITLE")
      # Asserts that the page title is "PAGE TITLE" and there is only one title element
      |> assert_html("title", count: 1, text: "PAGE TITLE")
      # Asserts that the page title matches "PAGE" and there is only one title element
      |> assert_html("title", count: 1, match: "PAGE")
      # Asserts that the page has one link with href value "/signup"
      |> assert_html("a[href='/signup']", count: 1)
      # Asserts that the page has at least one link
      |> assert_html("a", min: 1)
      # Asserts that the page has at most two links
      |> assert_html("a", max: 2)
      # Asserts that the page contains no forms
      |> refute_html("form")
    end
  end
  ```

  ### Selector Checks
  `assert_html(html, ".css .selector .exsits")` - Asserts that an element exists in the selector path.
  `refute_html(html, ".css .selector")` - Asserts that an element does not exist in the selector path.

  ### Check Attributes
  Supports meta attributes:

  * `:text` – The exact text within the element
  * `:match` - A value that the element's text should contain.

  """

  alias AssertHTML.{Debug, Matcher}

  @collection_checks [:match, :count, :min, :max]

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
  | E#myid          | an `E` element with ID equal to "myid" |
  | E:not(s)        | an E element that does not match simple selector s |
  | E F             | an F element descendant of an E element |
  | E > F           | an F element child of an E element |
  | E + F           | an F element immediately preceded by an E element |
  | E ~ F           | an F element preceded by an E element |

  """
  @type css_selector :: String.t()

  @typedoc """
  HTML response
  """
  @type html :: String.t()

  @typep matcher :: :assert | :refute

  @type context :: {matcher, html}

  @typedoc """
  HTML element attributes
  """
  @type attributes :: [{attribute_name, value}]

  @typedoc """
  Checking value
  - if nil should not exist

  """
  @type value :: nil | String.t() | Regex.t()

  @typedoc """
  HTML element attribute name
  """
  @type attribute_name :: atom() | binary()

  @typep block_fn :: (html -> any())

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

  @doc ~S"""
  Asserts an attributes in HTML element

  ## Asserting Attributes
  - `:text` – Asserts the exact text within an HTML element.
  - `:match` - Asserts that the HTML element's text contains a specific value.

  ```elixir
  iex> html = ~S{<div class="foo bar"></div><div class="zoo bar"></div>}
  ...> assert_html(html, ".zoo", class: "bar zoo")
  ~S{<div class="foo bar"></div><div class="zoo bar"></div>}

  # Check if `id` attribute does not exist
  iex> assert_html(~S{<div>text</div>}, id: nil)
  "<div>text</div>"
  ```

  #### Examples for :text

  Asserts the exact text within an HTML element.

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

  `assert_html(html, "css selector")`

  ```elixir
      iex> html = ~S{<p><div class="foo"><h1>Header</h1></div></p>}
      ...> assert_html(html, "p .foo h1")
      ~S{<p><div class="foo"><h1>Header</h1></div></p>}

      iex> html = ~S{<p><div class="foo"><h1>Header</h1></div></p>}
      ...> assert_html(html, "h1")
      ~S{<p><div class="foo"><h1>Header</h1></div></p>}
  ```

  ## Match elements in HTML

  Asserts that the HTML contains a specific element.

  ```elixir
      assert_html(html, ~r{<p>Hello</p>})
      assert_html(html, match: ~r{<p>Hello</p>})
      assert_html(html, match: "<p>Hello</p>")
  ```

  ### Asserts a text element in HTML

      iex> html = ~S{<p><div class="foo"><h1>Header</h1></div></p>}
      ...> assert_html(html, "p .foo h1", text: "Header")
      ~S{<p><div class="foo"><h1>Header</h1></div></p>}


  ### Examples

      iex> html = ~S{<div class="container">   <h1 class="title">Hello World</h1>   </div>}
      ...> assert_html(html, "h1", "Hello World") == html
      true

      iex> html = ~S{<div class="container">   <h1 class="title">Hello World</h1>   </div>}
      ...> assert_html(html, ".title", ~r{World})
      ~S{<div class="container">   <h1 class="title">Hello World</h1>   </div>}

  ## assert elements in selector
      assert_html(html, ".container table", ~r{<p>Hello</p>})
  """
  @spec assert_html(html, Regex.t()) :: html | no_return()
  def assert_html(html, %Regex{} = value) do
    html(:assert, html, nil, match: value)
  end

  @spec assert_html(html, block_fn) :: html | no_return()
  def assert_html(html, block_fn) when is_binary(html) and is_function(block_fn) do
    html(:assert, html, nil, nil, block_fn)
  end

  @spec assert_html(html, css_selector) :: html | no_return()
  def assert_html(html, css_selector) when is_binary(html) and is_binary(css_selector) do
    html(:assert, html, css_selector)
  end

  @spec assert_html(html, attributes) :: html | no_return()
  def assert_html(html, attributes) when is_binary(html) and is_list(attributes) do
    html(:assert, html, nil, attributes)
  end

  @spec assert_html(html, Regex.t(), block_fn) :: html | no_return()
  def assert_html(html, %Regex{} = value, block_fn)
      when is_binary(html) and is_function(block_fn) do
    html(:assert, html, nil, [match: value], block_fn)
  end

  @spec assert_html(html, attributes, block_fn) :: html | no_return()
  def assert_html(html, attributes, block_fn)
      when is_binary(html) and is_list(attributes) and is_function(block_fn) do
    html(:assert, html, nil, attributes, block_fn)
  end

  @spec assert_html(html, css_selector, block_fn) :: html | no_return()
  def assert_html(html, css_selector, block_fn)
      when is_binary(html) and is_binary(css_selector) and is_function(block_fn) do
    html(:assert, html, css_selector, nil, block_fn)
  end

  def assert_html(html, css_selector, attributes, block_fn \\ nil)

  @spec assert_html(html, css_selector, value, block_fn | nil) :: html | no_return()
  def assert_html(html, css_selector, %Regex{} = value, block_fn)
      when is_binary(html) and is_binary(css_selector) do
    html(:assert, html, css_selector, [match: value], block_fn)
  end

  def assert_html(html, css_selector, value, block_fn)
      when is_binary(html) and is_binary(css_selector) and is_binary(value) do
    html(:assert, html, css_selector, [match: value], block_fn)
  end

  @spec assert_html(html, css_selector, attributes, block_fn | nil) :: html | no_return()
  def assert_html(html, css_selector, attributes, block_fn) do
    html(:assert, html, css_selector, attributes, block_fn)
  end

  ###################################
  ### Refute

  @doc ~S"""
  Opposite method for assert_html

  See more (t:refute_html/2)
  """
  @spec refute_html(html, Regex.t()) :: html | no_return()
  def refute_html(html, %Regex{} = value) do
    html(:refute, html, nil, match: value)
  end

  @spec refute_html(html, css_selector) :: html | no_return()
  def refute_html(html, css_selector) when is_binary(html) and is_binary(css_selector) do
    html(:refute, html, css_selector)
  end

  @spec refute_html(html, attributes) :: html | no_return()
  def refute_html(html, attributes) when is_binary(html) and is_list(attributes) do
    html(:refute, html, nil, attributes)
  end

  @spec refute_html(html, Regex.t(), block_fn) :: html | no_return()
  def refute_html(html, %Regex{} = value, block_fn)
      when is_binary(html) and is_function(block_fn) do
    html(:refute, html, nil, [match: value], block_fn)
  end

  @spec refute_html(html, attributes, block_fn) :: html | no_return()
  def refute_html(html, attributes, block_fn)
      when is_binary(html) and is_list(attributes) and is_function(block_fn) do
    html(:refute, html, nil, attributes, block_fn)
  end

  @spec refute_html(html, css_selector, block_fn) :: html | no_return()
  def refute_html(html, css_selector, block_fn)
      when is_binary(html) and is_binary(css_selector) and is_function(block_fn) do
    html(:refute, html, css_selector, nil, block_fn)
  end

  def refute_html(html, css_selector, attributes, block_fn \\ nil)

  @spec refute_html(html, css_selector, value, block_fn | nil) :: html | no_return()
  def refute_html(html, css_selector, %Regex{} = value, block_fn) do
    html(:refute, html, css_selector, [match: value], block_fn)
  end

  def refute_html(html, css_selector, value, block_fn)
      when is_binary(html) and is_binary(css_selector) and is_binary(value) do
    html(:refute, html, css_selector, [match: value], block_fn)
  end

  @spec refute_html(html, css_selector, attributes, block_fn | nil) :: html | no_return()
  def refute_html(html, css_selector, attributes, block_fn) do
    html(:refute, html, css_selector, attributes, block_fn)
  end

  defp html(matcher, html_content, css_selector, attributes \\ nil, block_fn \\ nil)

  defp html(matcher, html_content, css_selector, nil = _attributes, block_fn) do
    html(matcher, html_content, css_selector, [], block_fn)
  end

  defp html(matcher, html_content, css_selector, attributes, block_fn) when is_map(attributes) do
    attributes = Enum.into(attributes, [])
    html(matcher, html_content, css_selector, attributes, block_fn)
  end

  defp html(matcher, html_content, css_selector, attributes, block_fn)
       when matcher in [:assert, :refute] and
              is_binary(html_content) and
              (is_binary(css_selector) or is_nil(css_selector)) and
              is_list(attributes) and
              (is_function(block_fn) or is_nil(block_fn)) do
    Debug.log("call .html with arguments: #{inspect(binding())}")

    params = {collection_params, attributes_params} = Keyword.split(attributes, @collection_checks)

    context = {matcher, html_content}

    # check selector
    check_selector(params, context, css_selector)

    # collection checks (:count, :min, :max and :match collection)
    check_collection(collection_params, context, css_selector)

    # check element attributes
    check_element(attributes_params, context, css_selector)

    # call inside block
    if block_fn do
      sub_html_content = get_sub_html!(context, css_selector, once: true)
      block_fn.(sub_html_content)
    end

    html_content
  end

  defp check_element(attributes, context, css_selector)

  defp check_element([], _context, _css_selector) do
    :skip
  end

  defp check_element(attributes, {matcher, html}, css_selector) do
    sub_html_content = get_sub_html!({matcher, html}, css_selector, once: true, skip_refute: true)

    Matcher.attributes({matcher, sub_html_content}, attributes)
  end

  defp check_collection([], _context, _css_selector) do
    :skip
  end

  # assert check selection exists
  defp check_collection(attributes, {matcher, _html} = context, css_selector) do
    # check :match meta-attribute
    {contain_value, attributes} = Keyword.pop(attributes, :match)

    if contain_value do
      sub_html_content = get_sub_html!(context, css_selector, once: true, skip_refute: true)
      Matcher.contain({matcher, sub_html_content}, contain_value)
    end

    # check :count meta-attribute
    {count_value, attributes} = Keyword.pop(attributes, :count)
    count_value && Matcher.count(context, css_selector, count_value)

    #  check :min meta-attribute
    {min_value, attributes} = Keyword.pop(attributes, :min)
    min_value && Matcher.min(context, css_selector, min_value)

    # check :max meta-attribute
    {max_value, _attributes} = Keyword.pop(attributes, :max)
    max_value && Matcher.max(context, css_selector, max_value)
  end

  defp get_sub_html!({_matcher, html_content}, nil, _options) do
    html_content
  end

  defp get_sub_html!(context, css_selector, options) do
    Matcher.selector(context, css_selector, options)
  end

  defp check_selector(params, context, css_selector)

  defp check_selector({[], []}, context, css_selector) do
    get_sub_html!(context, css_selector, once: true)
  end

  defp check_selector({[], _}, context, css_selector) do
    get_sub_html!(context, css_selector, once: true, skip_refute: true)
  end

  defp check_selector({_, []}, context, css_selector) do
    get_sub_html!(context, css_selector, skip_refute: true)
  end

  defp check_selector(_params, _mc, _css_selector) do
    :ok
  end
end

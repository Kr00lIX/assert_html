# AssertHTML: Elixir Library for testing HTML and XML using CSS selectors

[![Build Status](https://travis-ci.org/Kr00lIX/assert_html.svg?branch=master)](https://travis-ci.org/Kr00lIX/assert_html)
[![Hex pm](https://img.shields.io/hexpm/v/assert_html.svg?style=flat)](https://hex.pm/packages/assert_html)
[![Coverage Status](https://coveralls.io/repos/github/Kr00lIX/assert_html/badge.svg?branch=master)](https://coveralls.io/github/Kr00lIX/assert_html?branch=master)
 
AssertHTML is a powerful Elixir library designed for parsing and extracting data from HTML and XML using CSS. It also provides ExUnit assert helpers for testing rendered HTML using CSS selectors, making it an essential tool for Phoenix Controller and Integration tests.

## Features

- **HTML and XML Parsing**: Easily parse and extract data from HTML and XML documents.
- **CSS Selectors**: Use CSS selectors to find and manipulate elements in your HTML or XML.
- **ExUnit Assert Helpers**: Test your rendered HTML with the help of ExUnit assert helpers.

## Getting Started

Follow these steps to get started with AssertHTML:

1. **Install the Library**: Add `assert_html` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:assert_html, "~> 0.1"}
  ]
end
```

Then run `mix deps.get` to fetch the dependency.

2. **Import formating**: Update your .formatter.exs file with the following import:

```elixir
[
  import_deps: [
    :assert_html
  ]
]
```

3. **Add the Library to your Test**: Add `AssertHTML` to your test file:

```elixir
use AssertHTML
```


## Usage

### Usage in Phoenix Controller and Integration Test

Assuming the `html_response(conn, 200)` returns:

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

An example controller test:

```elixir
defmodule YourAppWeb.PageControllerTest do
  use YourAppWeb.ConnCase, async: true

  test "should get index", %{conn: conn} do        
    resp_conn = conn
    |> get(Routes.page_path(conn, :index))

    html_response(resp_conn, 200)
    # The page title is "PAGE TITLE"
    |> assert_html("title", "PAGE TITLE")
    # The page title is "PAGE TITLE", and there is only one title element
    |> assert_html("title", count: 1, text: "PAGE TITLE")
    # The page title matches "PAGE", and there is only one title element
    |> assert_html("title", count: 1, match: "PAGE")
    # The page has one link with the href value "/signup"
    |> assert_html("a[href='/signup']", count: 1)
    # The page has at least one link
    |> assert_html("a", min: 1)
    # The page has at most two links
    |> assert_html("a", max: 2)
    # The page contains no forms
    |> refute_html("form")
  end
end
```

### Contains

`assert_html(html, ~r{Hello World})` - match string in HTML  
`refute_html(html, ~r{Another World})` - should not contain string in HTML

```elixir
assert_html(html, ".content") do
  assert_html(~r{Hello World})
end
```    
      
### CSS selectors

`assert_html(html, ".css .selector")` - checks if an element exists in the CSS selector path
`refute_html(html, ".errors .error")` - checks if an element does not exist in the path

### Check attributes

```elixir
assert_html(html, "form", class: "form", method: "post", action: "/session/login") do
  assert_html ".-email" do
    assert_html("label", text: "Email", for: "staticEmail", class: "col-form-label")
    assert_html("div input", type: "text", readonly: true, class: "form-control-plaintext", value: "email@example.com")
  end
  assert_html(".-password") do
    assert_html("label", text: "Password", for: "inputPassword")
    assert_html("div input", placeholder: "Password", type: "password", class: "form-control", id: "inputPassword")
  end

  assert_html("button", type: "submit", class: "primary")
end
```

### Example

```elixir
defmodule ExampleControllerTest do
  use ExUnit.Case, async: true
  use AssertHTML

  test "shows search form", %{conn: conn} do
    conn_resp = get(conn, Routes.page_path(conn, :new))
    assert response = html_response(conn_resp, 200)

    assert_html response do
      # Check if element exists in CSS selector path
      assert_html "p.description"

      # Check if element doesn't exist
      refute_html ".flash-message"

      # Assert form attributes
      assert_html "form.new_page", action: Routes.page_path(conn, :create), method: "post" do
        # Assert elements inside the `form.new_page` selector
        assert_html "label", class: "form-label", text: "Page name"
        assert_html "input", type: "text", class: "form-control", value: "", name: "page_name"
        assert_html "button", class: "form-button", text: "Submit"
      end
    end
  end
end
```

Documentation can be found at [https://hexdocs.pm/assert_html](https://hexdocs.pm/assert_html/AssertHTML.html).


## Contribution
Feel free to send your PR with proposals, improvements or corrections 😉.

## Author

Anatolii Kovalchuk (@Kr00liX)


## License

This software is licensed under [the MIT license](LICENSE.md).

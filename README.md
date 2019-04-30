# AssertHTML

[![Build Status](https://travis-ci.org/Kr00lIX/assert_html.svg?branch=master)](https://travis-ci.org/Kr00lIX/assert_html)
[![Hex pm](https://img.shields.io/hexpm/v/assert_html.svg?style=flat)](https://hex.pm/packages/assert_html)
[![Coverage Status](https://coveralls.io/repos/github/Kr00lIX/assert_html/badge.svg?branch=master)](https://coveralls.io/github/Kr00lIX/assert_html?branch=master)
 
 
AssertHTML is an Elixir library for parsing and extracting data from HTML and XML with CSS.		 AssertHTML adds ExUnit assert helpers for testing rendered HTML using CSS selectors.

It is very useful in Phoenix Controller and Integration tests.

 
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
    conn = conn
    |> get(Routes.page_path(conn, :index))

    html_response(conn, 200)
    # Page title is "PAGE TITLE"
    |> assert_html("title", "PAGE TITLE")
    # Page title is "PAGE TITLE" and there is only one title element
    |> assert_html("title", count: 1, text: "PAGE TITLE")
    # Page title matches "PAGE" and there is only one title element
    |> assert_html("title", count: 1, match: "PAGE")
    # Page has one link with href value "/signup"
    |> assert_html("a[href='/signup']", count: 1)
    # Page has at least one link
    |> assert_html("a", min: 1)
    # Page has at most two links
    |> assert_html("a", max: 2)
    # Page contains no forms
    |> refute_html("form")
  end
end
```

### Contains
  `assert_html(html, ~r{Hello World})` - match string in HTML  
  `refute_html(html, ~r{Another World})` - should not contain string in HTML

  ```
   assert_html(html, ".content") do
     assert_html(~r{Hello World})
   end
  ```    
      
### CSS selectors

`assert_html(html, ".css .selector")` - check element exists in CSS selector path

`refute_html(html, ".errors .error")` - element not exists in path

### Check attributes

```elixir
assert_html(html, "form", class: "form", method: "post", action: "/session/login") do
  assert_html ".-email" do
    assert_html("label", text: "Email", for: "staticEmail", class: "col-form-label")
    assert_html("div input", type: "text", readonly: true, class: "form-control-plaintext", value: "email@example.com")
  end
  assert_html(".-password") do
    assert_html("label", text: "Password", for: "inputPassword")
    assert_html("div input", placeholder: "Password", type: "password", class: "form-control", id: "inputPassword", placeholder: "Password")
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
      # Check element exists in CSS selector path
      assert_html "p.description"

      # element doesn't exists
      refute_html ".flash-message"

      # assert form attributes
      assert_html "form.new_page", action: Routes.page_path(conn, :create), method: "post" do
        # assert elements inside the `form.new_page` selector
        assert_html "label", class: "form-label", text: "Page name"
        assert_html "input", type: "text", class: "form-control", value: "", name: "page_name"
        assert_html "button", class: "form-button", text: "Submit"
      end
    end
  end
end
```

Documentation can be found at [https://hexdocs.pm/assert_html](https://hexdocs.pm/assert_html/AssertHTML.html).


## Installation

It's available in Hex, the package can be installed as:

Add `assert_html` to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:assert_html, ">= 0.0.1", only: :test}
  ]
end
```
Then run `mix deps.get` to get the package.


## Contribution
Feel free to send your PR with proposals, improvements or corrections 😉.


## License

This software is licensed under [the MIT license](LICENSE.md).

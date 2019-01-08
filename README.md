# AssertHTML

AssertHTML is an Elixir library for parsing and extracting data from HTML and XML with CSS.


## Usage
```elixir
defmodule ExampleControllerTest do
  use ExUnit.Case, async: true
  use AssertHTML

  test "shows search form", %{conn: conn} do
    conn_resp = get(conn, Routes.page_path(conn, :new))
    assert response = html_response(conn_resp, 200)

    response
    |> assert_html_selector("p.description")
    |> refute_html_selector(".flash-message")
    |> assert_html_attributes("form.new_page", [action: Routes.page_path(conn, :create), method: "post"], fn(html)->
      html
      |> assert_html_attributes("label", class: "form-label", text: "Page name")
      |> assert_html_attributes("input", type: "text", class: "form-control", value: "", name: "page_name")
      |> assert_html_attributes("button", class: "form-button", text: "Submit")
    end)
  end
end
```

See [HexDocs](https://hexdocs.pm/Kr00lIX/assert_html.html) for additional documentation.

## Helpers Available

- `assert_attributes(html, selector, [id: "name"], fn(sub_html)->   end)`
- `assert_html_selector(html, css_selector)`  
- `refute_html_selector((html, css_selector, value)`
- `assert_html_text(html, value)`  
- `assert_html_text(html, css_selector, value)`
- `refute_html_text(html, value)` 
- `refute_html_text((html, css_selector, value)`
- `html_selector(html, css_selector)` 
- `html_attribute(html, css_selector)`  
- `html_attribute(html, css_selector, name)`
- `html_text(html, css_selector)` 


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `assert_html` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:assert_html, ">= 0.0.0", only: [:test]}
  ]
end
```

## License
This software is licensed under the MIT license.

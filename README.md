# AssertHTML

AssertHTML is an Elixir library for parsing and extracting data from HTML and XML with CSS.


## Usage

### CSS selectors


`assert_html(html, ".css .selector")`

Check element exists in CSS selector path
`refute_html(html, ".errors .error")`

g

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

See [HexDocs](https://hexdocs.pm/Kr00lIX/assert_html.html) for additional documentation.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `assert_html` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:assert_html, ">= 0.0.1", only: [:test]}
  ]
end
```

## Contribution
Feel free to send your PR with proposals, improvements or corrections 😉.


## License
This software is licensed under the MIT license.

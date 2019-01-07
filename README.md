# AssertHtml

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
      |> assert_html_attributes("input", type: "text", class: "form-control", value: "", name: "page[name]")
      |> assert_html_attributes("button", class: "form-button", text: "Submit")
    end)
  end

  test "shows new page form", %{conn: conn} do
    conn_resp = get(conn, Routes.page_path(conn, :new))
    assert response = html_response(conn_resp, 200)

    response
    |> assert_html("title", "New page")
    |> assert_html("p.description", ~r{You can check text by regular expression})
    |> refute_html(".check .element .if_doesnt_exist")
    |> assert_html("form.new_page", action: Routes.page_path(conn, :create), method: "post") do
      assert_html(".control_group") do
        assert_html("label", class: "form-label", text: "Page name")
        assert_html("input", type: "text", class: "form-control", value: "", name: "page[name]")
      end
      assert_html("button", class: "form-button", text: "Submit")
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
    {:assert_html, ">= 0.0.0", only: [:test]}
  ]
end
```



## License
This software is licensed under the MIT license.

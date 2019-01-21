# Changelog

## Unreleased

## v0.0.2


## Fixed
- Checking attributes with non sting values
- Check no existing attributes `attribute_name: nil`

### Added
- Add `assert_html_contains(html, value)` and `refute_html_contains(html, value)` checkers
- Add `assert_html` macro for simplify DSL
  ```
  use AssertHTML

  test "shows new page form", %{conn: conn} do
      conn_resp = get(conn, Routes.page_path(conn, :new))
      assert response = html_response(conn_resp, 200)

      assert_html(response) do
        assert_html("title", "New page")
        assert_html("p.description", ~r{You can check text by regular expression})
        refute_html(".check .element .if_doesnt_exist")
        assert_html("form.new_page", action: Routes.page_path(conn, :create), method: "post") do
          assert_html(".control_group") do
              assert_html("label", class: "form-label", text: "Page name")
              assert_html("input", type: "text", class: "form-control", value: "", name: "page[name]")
            end
            assert_html("button", class: "form-button", text: "Submit")
          end
        end
      end
    end
  ```
### Deleted
- Delete `assert_html_contains(html, "text")` -> use `assert_html(html, ~r"text")` instead
- Delete `refute_html_contains(html, "text")` -> use `refute_html(html, ~r"text")` instead

- Delete `refute_html_selector(html, selector)` (use `refute_html(html, selector)` instead)

## v0.0.1

### Added
- Allow use Regexp for checking attribute value
- Add `assert_attributes(html, selector, [id: "name"], fn(sub_html)->   end)` callback with selected html
- Add `assert_attributes(html, selector, id: "name")` checker
- Add `assert_html_selector(html, css_selector)` and `refute_html_selector((html, css_selector, value)` checkers
- Add `assert_html_text(html, value)` and `assert_html_text(html, css_selector, value)` checkers
- Add `refute_html_text(html, value)` and `refute_html_text((html, css_selector, value)` checkers
- Add `html_selector(html, css_selector)` method
- Add `html_attribute(html, css_selector)` and `html_attribute(html, css_selector, name)`  methods
- Add `html_text(html, css_selector)` method
- Basic ExDoc configuration
- Markdown documentation (README, LICENSE, CHANGELOG)
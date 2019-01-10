defmodule AssertHTML.DSLTest do
  use ExUnit.Case, async: true
  import AssertHTML.DSL

  describe "(context definition)" do
    setup do
      [html: ~S{
        <div class="container">
          <h1>Title</h1>
          <p class="hard_decision">
            <a class="active link1">Yes</a>
            <a class="link2">No</a>
          </p>
        </div>
    }]
    end

    test "gets context html for defining context", %{html: html} do
      assert_html(html) do
        assert assert_html ==  "\n        <div class=\"container\">\n          <h1>Title</h1>\n          <p class=\"hard_decision\">\n            <a class=\"active link1\">Yes</a>\n            <a class=\"link2\">No</a>\n          </p>\n        </div>\n    "
        assert_html("p") do
          assert assert_html == "<p class=\"hard_decision\"><a class=\"active link1\">Yes</a><a class=\"link2\">No</a></p>"
          assert_html |> IO.inspect(label: "html2")
          assert_html("a.link1", class: "active", text: "Yes")
          assert_html("a.link2", class: nil, text: "No")
        end
      end
    end

    test "use macro for defining context with selector" do
      html = ~S{
          <p id="aaa">
            <a class="link">Click me</a>
          </p>
      }
      assert_html(html, "p") do
        assert_html("a", class: "link", text: "Click me", id: nil)
      end
    end

    test "use macro for defining context with selector and attributes" do
      html = ~S{
          <p class="foo" id="descr">
            <a class="link">Click me</a>
          </p>
      }
      assert_html(html, "p", class: "foo", id: "descr") do
        assert_html("a", class: "link", text: "Click me", id: nil)
      end
    end
  end
end

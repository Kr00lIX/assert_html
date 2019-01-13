defmodule AssertHTMLTest do
  use ExUnit.Case, async: true
  doctest AssertHTML, import: true
  import AssertHTML
  alias ExUnit.AssertionError


  describe "assert_html (check css selector)" do
    setup do
      [html: ~S{
        <div class="container">
          <h1>Hello</h1>
          <p class="description">
            Paragraph
          </p>
          <h1>World</h1>
        </div>
      }]
    end

    test "expect match selector", %{html: html} do
      assert_html(html, "p")
      assert_html(html, ".container .description")

      refute_html(html, "table")
      refute_html(html, ".container h5")
    end

    test "expect pass to caballack selected html", %{html: html} do
      result_html = assert_html(html, ".container", fn(sub_html)->
        assert sub_html == "<div class=\"container\"><h1>Hello</h1><p class=\"description\">\n            Paragraph\n          </p><h1>World</h1></div>"
        assert_html(sub_html, ".description", fn(sub_html)->
          assert sub_html ==  "<p class=\"description\">\n            Paragraph\n          </p>"
        end)
      end)
      assert result_html == "\n        <div class=\"container\">\n          <h1>Hello</h1>\n          <p class=\"description\">\n            Paragraph\n          </p>\n          <h1>World</h1>\n        </div>\n      "
    end

    test "raise AssertionError exception for unmatched selection", %{html: html} do
      message = "\n\nElement `.invalid .selector` not found.\n     \n     \t\n             <div class=\"container\">\n               <h1>Hello</h1>\n               <p class=\"description\">\n                 Paragraph\n               </p>\n               <h1>World</h1>\n             </div>\n           \n     \n"
      assert_raise AssertionError, message, fn  ->
        assert_html(html, ".invalid .selector")
      end

      message = "\n\nSelector `.container h1` succeeded, but should have failed.\n     \n     \t\n             <div class=\"container\">\n               <h1>Hello</h1>\n               <p class=\"description\">\n                 Paragraph\n               </p>\n               <h1>World</h1>\n             </div>\n           \n     \n"
      assert_raise AssertionError, message, fn ->
        refute_html(html, ".container h1")
      end
    end
  end

  describe ".assert_html (check attributes)" do
    setup do
      html = ~S{
        <div id="main" class="container">
          <h1>Hello</h1>
          <p class="description highligh">
            Long Read Paragraph
          </p>
          World
        </div>
      }
      [html: html]
    end

    test "expect pass equal attributes", %{html: html} do
      assert_html(html, "#main", [class: "container", id: "main", text: "World"], fn(sub_html) ->
        assert_html(sub_html, "h1", class: nil, text: "Hello")
        refute_html(sub_html, "h2")
        assert_html(sub_html, "p", class: "highligh", text: ~r"Read")
      end)
    end
  end
end

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
      result_html =
        assert_html(html, ".container", fn sub_html ->
          assert sub_html == "<div class=\"container\"><h1>Hello</h1><p class=\"description\">\n            Paragraph\n          </p><h1>World</h1></div>"

          assert_html(sub_html, ".description", fn sub_html ->
            assert sub_html == "<p class=\"description\">\n            Paragraph\n          </p>"
          end)
        end)

      assert result_html ==
               "\n        <div class=\"container\">\n          <h1>Hello</h1>\n          <p class=\"description\">\n            Paragraph\n          </p>\n          <h1>World</h1>\n        </div>\n      "
    end

    test "raise AssertionError exception for unmatched selection", %{html: html} do
      assert_raise AssertionError, ~r{Element `.invalid .selector` not found.}, fn ->
        assert_html(html, ".invalid .selector")
      end

      assert_raise AssertionError, ~r{Selector `.container h1` succeeded, but should have failed}, fn ->
        refute_html(html, ".container h1")
      end
    end
  end

  describe ".assert_html (check attributes)" do
    setup do
      html = ~S{
        <div id="main" class="container">
          <h1>Hello</h1>
          <p class="description highlight">
            Long Read Paragraph
          </p>
          <p>
            Second Paragraph
          </p>
          World
        </div>
      }
      [html: html]
    end

    test "expect count meta-attribute to equal number of elements found", %{html: html} do
      assert_html(html, "#main", [count: 1], fn sub_html ->
        assert_html(sub_html, "h1", count: 1)
        assert_html(sub_html, "p", count: 2)
      end)
    end

    test "expect min meta-attribute that number of elements found is greater than or equal",
      %{html: html} do
      assert_html(html, "#main", [min: 1], fn sub_html ->
        assert_html(sub_html, "h1", min: 1)
        assert_html(sub_html, "p", min: 2)
      end)
    end

    test "expect max meta-attribute that number of elements found is less than or equal",
      %{html: html} do
      assert_html(html, "#main", [max: 1], fn sub_html ->
        assert_html(sub_html, "h1", max: 1)
        assert_html(sub_html, "p", max: 2)
      end)
    end

    test "expect pass equal attributes", %{html: html} do
      assert_html(html, "#main", [class: "container", id: "main", text: "World"], fn sub_html ->
        assert_html(sub_html, "h1", class: nil, text: "Hello")
        refute_html(sub_html, "h2")
        assert_html(sub_html, "p", class: "highlight", text: ~r"Read")
      end)
    end
  end

  describe ".assert_html (check contains)" do
    setup do
      [html: ~S{
        <div class="content">
          <h1>Hello World</h1>
        </div>
      }]
    end

    test "expect find contain text", %{html: html} do
      assert_html(html, ~r{Hello World})
      refute_html(html, ~r{Another World})

      assert_html(html, ".content", fn sub_html ->
        assert_html(sub_html, ~r{Hello World})
      end)
    end

    test "check contains in selector", %{html: html} do
      assert_raise AssertionError, ~r"Value not matched.", fn ->
        assert_html(html, "h1", ~r{Hello World!!!!})
      end

      assert_html(html, "h1", ~r{Hello World})
      assert_html(html, "h1", "Hello World")

      assert_raise AssertionError, ~r"Value not found", fn ->
        assert_html(html, "h1", "Hello World!!!!")
      end

      refute_html(html, "h1", match: "Hello World!!!")
    end

    test "check contains as second argument", %{html: html} do
      refute_html(html, "h1", ~r{Hello World!!!!})

      assert_raise AssertionError, ~r"Value `~r/Hello World/` matched, but shouldn't.", fn ->
        refute_html(html, "h1", ~r{Hello World})
      end

      assert_raise AssertionError, ~r{Value `"Hello World"` found, but shouldn't.}, fn ->
        refute_html(html, "h1", "Hello World")
      end

      refute_html(html, "h1", "Hello World!!!!")
    end

    test "check match as attribute argument", %{html: html} do
      assert_html(html, match: "Hello World")

      assert_raise AssertionError, ~r"Value not found", fn ->
        assert_html(html, "h1", match: "Hello World!!!!")
      end

      refute_html(html, match: "Hello World!!!!")
    end
  end
end

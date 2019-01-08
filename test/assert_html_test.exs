defmodule AssertHTMLTest do
  use ExUnit.Case, async: true
  doctest AssertHTML, import: true
  import AssertHTML
  alias ExUnit.AssertionError

  describe ".html_selector" do
    setup do
      html = ~S{
        <div class="container">
          <h1>Hello</h1>
          <p class="descripition">
            Paragraph
          </p>
          <h1>World</h1>
        </div>
      }
      [html: html]
    end

    test "expect returns full HTML for select root element", %{html: html} do
      result_html = "<div class=\"container\"><h1>Hello</h1><p class=\"descripition\">\n            Paragraph\n          </p><h1>World</h1></div>"

      assert html_selector(html, "div.container") == result_html
    end

    test "find element inside HTML", %{html: html} do
      assert html_selector(html, "h1:first-child") == "<h1>Hello</h1>"

      assert html_selector(html, ".descripition") == "<p class=\"descripition\">\n            Paragraph\n          </p>"
    end

    test "expect returns multiply elements", %{html: html} do
      assert html_selector(html, "div h1") == "<h1>Hello</h1><h1>World</h1>"
    end

    test "returns nil if element not found", %{html: html} do
      assert html_selector(html, "div h1 h2 h3 h4") == nil
      assert html_selector(html, ".find-me") == nil
    end
  end

  describe ".html_attribute" do
    test "returns attribute from element" do
      html = ~S{<div class="foo bar" id="container" data=""></div>}
      assert html_attribute(html, "class") == "foo bar"
      assert html_attribute(html, "id") == "container"
      assert html_attribute(html, "data") == ""
    end

    test "returns nil for not found attribute" do
      assert html_attribute("<p></p>", "class") == nil
      assert html_attribute("", "class") == nil
    end
  end

  describe ".html_text/2" do
    setup do
      [
        html: ~S{
          <div class="container">
            <h1>Hello</h1>
            <p class="descripition">
              Paragraph
            </p>
          </div>
        }
      ]
    end

    test "returns text from html element", %{html: html} do
      assert html_text(html, "h1") == "Hello"
      assert html_text(html, ".container .descripition") == "Paragraph"
      assert html_text(html, ".descripition .invalid") == ""
      assert html_text(html, ".descripition form") == ""
    end
  end

  describe ".assert_html_selector" do
    setup do
      [
        html: ~S{
          <div class="container">
            <h1>Hello</h1>
            <p class="descripition">
              Paragraph
            </p>
          </div>
        }
      ]
    end

    test "do not raise exception for valid selector", %{html: html} do
      returns_html = assert_html_selector(html, ".container h1")
      assert html == returns_html
    end

    test "raise AssertionError for invalid selector", %{html: html} do
      message =
        "\n\nElement `.container p p` not found.\n     \n     \t\n               <div class=\"container\">\n                 <h1>Hello</h1>\n                 <p class=\"descripition\">\n                   Paragraph\n                 </p>\n               </div>\n             \n     \n"

      assert_raise AssertionError, message, fn ->
        assert_html_selector(html, ".container p p")
      end
    end
  end

  describe ".refute_html_selector" do
    setup do
      [
        html: ~S{
          <div class="container">
            <h1>Hello</h1>
            <p class="descripition">
              Paragraph
            </p>
          </div>
        }
      ]
    end

    test "do not raise exception for invalid selector", %{html: html} do
      returns_html = refute_html_selector(html, "h1 h2 h3")
      assert html == returns_html
    end

    test "raise AssertionError for valid selector", %{html: html} do
      message =
        "\n\nSelector `.container p` succeeded, but should have failed.\n     \n     \t\n               <div class=\"container\">\n                 <h1>Hello</h1>\n                 <p class=\"descripition\">\n                   Paragraph\n                 </p>\n               </div>\n             \n     \n"

      assert_raise ExUnit.AssertionError, message, fn ->
        refute_html_selector(html, ".container p")
      end
    end
  end

  describe ".assert_html_attributes" do
    setup do
      [html: ~S{
        <div class="foo" id="main">
          <div class="bar">Text</div>
        </div>}]
    end

    test "check attributes", %{html: html} do
      assert_html_attributes(html, ".foo", [id: "main"], fn sub_html ->
        assert_html_attributes(sub_html, ".bar", text: "Text")
      end)
    end
  end

  describe ".assert_html_text" do
    setup do
      [
        html: ~S{
          <div class="container">
            <h1>Hello World</h1>
            <p class="descripition">
              Paragraph
            </p>
          </div>
        }
      ]
    end

    test "raise AssertionError for invalid selector", %{html: html} do
      message =
        "\n\nElement `.container p p` not found.\n     \n     \t\n               <div class=\"container\">\n                 <h1>Hello World</h1>\n                 <p class=\"descripition\">\n                   Paragraph\n                 </p>\n               </div>\n             \n     \n"

      assert_raise AssertionError, message, fn ->
        assert_html_text(html, ".container p p", "Hello World")
      end
    end

    test "raise AssertionError for valid selector and invalid value", %{html: html} do
      message = "\n\nComparison (using ==) failed in:\nleft:  \"Hello World\"\nright: \"World\"\n"

      assert_raise AssertionError, message, fn ->
        assert_html_text(html, "h1", "World")
      end
    end

    test "do not raise exception for valid selector", %{html: html} do
      returns_html = assert_html_text(html, ".container h1", "Hello World")
      assert html == returns_html
    end

    test "check value via regular expression", %{html: html} do
      returns_html = assert_html_text(html, ".container h1", ~r"Hello")
      assert html == returns_html
    end
  end

  describe ".refute_html_text" do
    setup do
      [
        html: ~S{
          <div class="container">
            <h1>Hello World</h1>
            <p class="descripition">
              Paragraph
            </p>
          </div>
        }
      ]
    end

    test "no raise AssertionError for invalid selector", %{html: html} do
      assert html == refute_html_text(html, ".container p", "World")
    end

    test "raise AssertionError for valid selector and valid value", %{html: html} do
      message = "\n\nComparison (using !=) failed in:\nleft:  \"Hello World\"\nright: \"Hello World\"\n"

      assert_raise AssertionError, message, fn ->
        refute_html_text(html, "h1", "Hello World")
      end
    end

    test "do not raise exception for valid selector and invalid value", %{html: html} do
      returns_html = refute_html_text(html, ".container h1", "Hello")
      assert html == returns_html
    end
  end

  describe ".assert_html_contains" do
    setup do
      [
        html: ~S{
          <div class="container">
            <h1>Hello World</h1>
            <p class="descripition">
              Paragraph
            </p>
          </div>
        }
      ]
    end

    test "raise AssertionError for invalid valid", %{html: html} do
      message =
        "\n\nValue `Help me` not found.\n     \n     \t\n               <div class=\"container\">\n                 <h1>Hello World</h1>\n                 <p class=\"descripition\">\n                   Paragraph\n                 </p>\n               </div>\n             \n     \n"

      assert_raise AssertionError, message, fn ->
        assert_html_contains(html, "Help me")
      end
    end

    test "do not raise exception for valid selector", %{html: html} do
      returns_html = assert_html_contains(html, "Hello World")
      assert html == returns_html
    end
  end

  describe ".refute_html_contains" do
    setup do
      [
        html: ~S{
          <div class="container">
            <h1>Hello World</h1>
            <p class="descripition">
              Paragraph
            </p>
          </div>
        }
      ]
    end

    test "raise AssertionError for valid value", %{html: html} do
      message =
        "\n\nValue `Hello World` found, but shouldn't.\n     \n     \t\n               <div class=\"container\">\n                 <h1>Hello World</h1>\n                 <p class=\"descripition\">\n                   Paragraph\n                 </p>\n               </div>\n             \n     \n"

      assert_raise AssertionError, message, fn ->
        refute_html_contains(html, "Hello World")
      end
    end

    test "do not raise exception for  invalid value", %{html: html} do
      returns_html = refute_html_contains(html, "Hugs")
      assert html == returns_html
    end
  end
end

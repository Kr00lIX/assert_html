defmodule AssertHtmlTest do
  use ExUnit.Case, async: true
  doctest AssertHtml, import: true
  import AssertHtml
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
      result_html =
        "<div class=\"container\"><h1>Hello</h1><p class=\"descripition\">\n            Paragraph\n          </p><h1>World</h1></div>"

      assert html_selector(html, "div.container") == result_html
    end

    test "find element inside HTML", %{html: html} do
      assert html_selector(html, "h1:first-child") == "<h1>Hello</h1>"

      assert html_selector(html, ".descripition") ==
               "<p class=\"descripition\">\n            Paragraph\n          </p>"
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
      returns_html = assert_html_selector html, ".container h1"
      assert html == returns_html
    end

    test "raise AssertionError for invalid selector", %{html: html} do
      message = "\n\nSelector `.container p p` not found in HTML\n      \n               <div class=\"container\">\n                 <h1>Hello</h1>\n                 <p class=\"descripition\">\n                   Paragraph\n                 </p>\n               </div>\n             \n"
      assert_raise AssertionError, message, fn ->
        assert_html_selector html, ".container p p"
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
      returns_html = refute_html_selector html, "h1 h2 h3"
      assert html == returns_html
    end

    test "raise AssertionError for valid selector", %{html: html} do
      message =  "\n\nSelector `.container p` succeeded, but should have failed.\n      \n               <div class=\"container\">\n                 <h1>Hello</h1>\n                 <p class=\"descripition\">\n                   Paragraph\n                 </p>\n               </div>\n             \n     \n"
      assert_raise ExUnit.AssertionError, message, fn ->
        refute_html_selector html, ".container p"
      end
    end
  end

  describe ".assert_html_attributes" do
    test ""
  end

  describe ".assert_html_text" do
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

    test "raise AssertionError for invalid selector", %{html: html} do
      message = "\n\nSelector `.container p p` not found in HTML\n      \n               <div class=\"container\">\n                 <h1>Hello</h1>\n                 <p class=\"descripition\">\n                   Paragraph\n                 </p>\n               </div>\n             \n"
      assert_raise AssertionError, message, fn ->
        assert_html_text html, ".container p p", "Hello"
      end
    end

    test "raise AssertionError for valid selector and invalid value", %{html: html} do
      message = ""
      assert_raise AssertionError, message, fn ->
        assert_html_text html, "h1", "World"
      end
    end

    test "do not raise exception for valid selector", %{html: html} do
      returns_html = assert_html_text html, ".container h1", "Hello"
      assert html == returns_html
    end
  end

  describe ".refute_html_text" do
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

    test "raise AssertionError for invalid selector", %{html: html} do
      message = ""
      assert_raise AssertionError, message, fn ->
        refute_html_text html, ".container p", "World"
      end
    end

    test "raise AssertionError for valid selector and valid value", %{html: html} do
      message = ""
      assert_raise AssertionError, message, fn ->
        refute_html_text html, "h1", "World"
      end
    end

    test "do not raise exception for valid selector and invalid value", %{html: html} do
      returns_html = refute_html_text html, ".container h1", "Hello"
      assert html == returns_html
    end
  end

  describe ".assert_match_html_text" do
    test ""
  end

  describe ".refute_match_html_text" do
    test ""
  end

end

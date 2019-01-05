defmodule AssertHtmlTest do
  use ExUnit.Case
  doctest AssertHtml, import: true
  import AssertHtml

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

  test ".html_text/2" do
    html = ~S{
      <div class="container">
        <h1>Hello</h1>
        <p class="descripition">
          Paragraph
        </p>
      </div>
    }

    assert html_text(html, "h1") == "Hello"
    assert html_text(html, ".container .descripition") == "Paragraph"
    assert html_text(html, ".descripition .invalid") == ""
    assert html_text(html, ".descripition form") == ""
  end

  describe ".assert_html_selector" do
    assert_html_selector
  end

  describe ".refute_html_selector" do
  end

  # test ".assert_html/2" do

  # end

  # test ".refute_html/2" do

  # end

  # test ".assert_html_text/2" do

  # end

  # test ".refute_html_text/2" do

  # end

  # test ".html_exists?/2" do

  # end

  # test ".html_text?/2" do

  # end
end

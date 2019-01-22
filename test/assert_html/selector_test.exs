defmodule AssertHTMLTest.SelectorTest do
  use ExUnit.Case, async: true
  doctest AssertHTML.Selector, import: true
  import AssertHTML.Selector

  describe ".attribute/2" do
    setup do
      [html: ~S{<a id="cta" class="red bold">Click Me</a>}]
    end

    test "get inner text for `text` attribute", %{html: html} do
      assert attribute(html, "text") == "Click Me"
    end

    test "expect returns unparsed class attribute for element", %{html: html} do
      assert attribute(html, "class") == "red bold"
    end

    test "expect get attribute by atom name", %{html: html} do
      assert attribute(html, :id) == "cta"
    end

    test "expect returns nil for non exsising attribute", %{html: html} do
      assert attribute(html, "data") == nil
    end
  end

  describe ".text/2" do
    test "returns text from attribute" do
      assert text(~S{<a class="foo">Click Me</a>}) == "Click Me"
    end

    test "expect get unescaped text" do
      assert text(~S{<p>M &amp; F</a>}) == "M & F"
    end

    test "expect get emptry string if not exists" do
      assert text(~S{<input name="surname" />}) == ""
    end
  end
end

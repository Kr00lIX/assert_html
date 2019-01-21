defmodule AssertHTMLTest.MatcherTest do
  use ExUnit.Case, async: true
  doctest AssertHTML.Matcher, import: true
  import AssertHTML.Matcher
  alias ExUnit.AssertionError

  describe ".attributes/3" do
    setup do
      [
        html: ~S{<main class="table -vertical">quotes: &quot; &amp; &#39;</main>}
      ]
    end

    test "raise error for unexpected attribute", %{html: html} do
      message = ~r{Attribute `class` matched, but should haven't matched.}
      assert_raise AssertionError, message, fn ->
        attributes(html, class: nil)
      end
    end

    test "expect check `class` attribute splitted by space", %{html: html} do
      attributes(html, class: "table")
      attributes(html, class: "table -vertical")
      attributes(html, class: "-vertical")

      message = ~r{Class `wrong_class` not found in `table -vertical` class attribute}
      assert_raise AssertionError, message, fn ->
        attributes(html, class: "wrong_class")
      end
    end

    test "expect check escaped text from `text` attribute", %{html: html} do
      attributes(html, text: "quotes: \" & '")
      attributes(html, text: ~r"quotes:")
    end

    test "expect error if attribute not exsists", %{html: html} do
      message = "\n\nAttribute `id` not found.\n     \n     \t<main class=\"table -vertical\">quotes: &quot; &amp; &#39;</main>\n     \n"
      assert_raise AssertionError, message, fn ->
        attributes(html, id: "new_element")
      end
    end

    test "expect stringify values for checking attribuites" do
      html = ~S{<input id="zoo" value="111" />}
      attributes(html, value: 111, id: "zoo")
    end

    test "check if attribute not exsists" do
      html = ~S{<input type="checkbox" value="111" />}
      attributes(html, type: "checkbox", checked: nil)
    end

    test "check if attribute exsists" do
      html = ~S{<input type="text" readonly value="hahaha" />}
      attributes(html, type: "text", readonly: true)
    end
  end

  describe ".contain" do
    setup do
      [html: ~S{<div><p>Merry Christmas</p></div>}]
    end

    test "expect check value", %{html: html} do
      contain(:assert, html, ~r"Merry Christmas")
      contain(:assert, html, ~r"<p>Merry Christmas")
    end
  end
end

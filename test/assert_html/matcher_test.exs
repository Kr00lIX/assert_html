defmodule AssertHTMLTest.MatcherTest do
  use ExUnit.Case, async: true
  doctest AssertHTML.Matcher, import: true
  import AssertHTML.Matcher
  alias ExUnit.AssertionError

  describe ".assert_attributes/4" do
    setup do
      [
        html: ~S{<main class="table -vertical">quotes: &quot; &amp; &#39;</main>}
      ]
    end

    test "expect error for invalid selector", %{html: html} do
      message = "\n\nElement `zzz ffff` not found.\n     \n     \t<main class=\"table -vertical\">quotes: &quot; &amp; &#39;</main>\n     \n"

      assert_raise AssertionError, message, fn ->
        assert_attributes(html, "zzz ffff", id: "foo")
      end
    end

    test "raise error for unexpected attribute", %{html: html} do
      message =
        "\n\nAttribute `class` matched, but should haven't matched.\n     \n     \t<main class=\"table -vertical\">quotes: &quot; &amp; &apos;</main>.\n     \n"

      assert_raise AssertionError, message, fn ->
        assert_attributes(html, "main", class: nil)
      end
    end

    test "expect check `class` attribute splitted by space", %{html: html} do
      assert_attributes(html, "main", class: "table")
      assert_attributes(html, "main", class: "table -vertical")
      assert_attributes(html, "main", class: "-vertical")

      message =
        "\n\nClass `wrong_class` not found in `table -vertical` class attribute\n     \n     \t<main class=\"table -vertical\">quotes: &quot; &amp; &apos;</main>\n     \n"

      assert_raise AssertionError, message, fn ->
        assert_attributes(html, "main", class: "wrong_class")
      end
    end

    test "expect check escaped text from `text` attribute", %{html: html} do
      assert_attributes(html, "main", text: "quotes: \" & '")
      assert_attributes(html, "main", text: ~r"quotes:")
    end

    test "expect error if attribute not exsists", %{html: html} do
      message = "\n\nElement `form` not found.\n     \n     \t<main class=\"table -vertical\">quotes: &quot; &amp; &#39;</main>\n     \n"

      assert_raise AssertionError, message, fn ->
        assert_attributes(html, "form", id: "new_element")
      end
    end

    test "expect stringify values for checking attribuites" do
      html = ~S{<input id="zoo" value="111" />}
      assert_attributes(html, "input", value: 111, id: "zoo")
    end

    test "check if attribute not exsists", %{html: html} do
      html = ~S{<input type="checkbox" value="111"  />}
      assert_attributes(html, "input", type: "checkbox", checked: nil)
    end
  end

  describe ".contain" do
    setup do
      [html: ~S{<div><p>Merry Christmas</p></div>}]
    end

    test "expect check value", %{html: html} do
      contain(:assert, html, "Merry Christmas")
      contain(:assert, html, "<p>Merry Christmas")
    end
  end
end

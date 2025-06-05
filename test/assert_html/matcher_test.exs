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
      assert_raise AssertionError, ~r{Attribute `class` shouldn't exists.}, fn ->
        attributes({:assert, html}, class: nil)
      end

      attributes({:refute, html}, class: nil)
    end

    test "expect check `class` attribute splitted by space", %{html: html} do
      attributes({:assert, html}, class: "table")
      attributes({:assert, html}, class: "table -vertical")
      attributes({:assert, html}, class: "-vertical")

      message = ~r{Class `wrong_class` not found in `table -vertical` class attribute}

      assert_raise AssertionError, message, fn ->
        attributes({:assert, html}, class: "wrong_class")
      end

      attributes({:refute, html}, class: "container")

      assert_raise AssertionError, ~r"Class `-vertical` found in `table -vertical` class attribute", fn ->
        attributes({:refute, html}, class: "-vertical")
      end
    end

    test "expect check escaped text from `text` attribute", %{html: html} do
      attributes({:assert, html}, text: "quotes: \" & '")
      attributes({:assert, html}, text: ~r"quotes:")
    end

    test "expect error if attribute not exsists", %{html: html} do
      message =
        "\n\nAttribute `id` not found.\n\n     \t<main class=\"table -vertical\">quotes: &quot; &amp; &#39;</main>\n\n"

      assert_raise AssertionError, message, fn ->
        attributes({:assert, html}, id: "new_element")
      end

      assert_raise AssertionError, ~r"Attribute `id` should exists.", fn ->
        attributes({:refute, html}, id: nil)
      end
    end

    test "expect stringify values for checking attribuites" do
      html = ~S{<input id="zoo" value="111" />}
      attributes({:assert, html}, value: 111, id: "zoo")
      attributes({:refute, html}, value: 222)
    end

    test "check if attribute not exsists" do
      html = ~S{<input type="checkbox" value="111" />}
      attributes({:assert, html}, type: "checkbox", checked: nil)
      attributes({:refute, html}, type: nil)
    end

    test "check if attribute exsists" do
      html = ~S{<input type="text" readonly value="hahaha" />}
      attributes({:assert, html}, type: "text", readonly: true)
      attributes({:refute, html}, type: "tel", readonly: false)

      assert_raise AssertionError, ~r"Attribute `readonly` shouldn't exists.", fn ->
        attributes({:assert, html}, readonly: false)
      end

      assert_raise AssertionError, ~r"Attribute `readonly` shouldn't exists.", fn ->
        attributes({:refute, html}, readonly: true)
      end
    end
  end

  describe ".contain" do
    setup do
      [html: ~S{<div><p>Merry Christmas</p></div>}]
    end

    test "expect check value", %{html: html} do
      contain({:assert, html}, ~r"Merry Christmas")
      contain({:assert, html}, ~r"<p>Merry Christmas</p>")
      contain({:refute, html}, ~r"Peper")
      contain({:refute, html}, ~r"<h2>Merry Christmas")
    end

    test "expect raise error for unmached value", %{html: html} do
      assert_raise AssertionError, ~r{Value `~r/Merry Christmas/` matched, but shouldn't.}, fn ->
        contain({:refute, html}, ~r"Merry Christmas")
      end

      assert_raise AssertionError, ~r"Value not matched.", fn ->
        contain({:assert, html}, ~r"<h2>Merry Christmas")
      end
    end
  end

  describe ".selector" do
    setup do
      [html: ~S{<main class="container"
        <ul>
          <li>One</li>
          <li>Two</li>
        </ul>
        </main>}]
    end

    test "assert: raise error if found more than two elements", %{html: html} do
      assert_raise AssertionError, ~r{Found more than one element by `.container li` selector}, fn ->
        selector({:assert, html}, ".container li", once: true)
      end
    end

    test "assert: returns HTML if element exsists", %{html: html} do
      assert selector({:assert, html}, ".container li:first-child") == "<li>One</li>"
    end

    test "refute: raise error if element exsists", %{html: html} do
      assert_raise AssertionError, ~r{Selector `.container li` succeeded, but should have failed.}, fn ->
        selector({:refute, html}, ".container li")
      end
    end

    test "assert: returns HTML if selection exsists", %{html: html} do
      assert selector({:assert, html}, ".container li") == "<li>One</li><li>Two</li>"
    end

    test "refute: raise error if selection exsists", %{html: html} do
      assert_raise AssertionError, ~r{Selector }, fn ->
        selector({:refute, html}, ".container li")
      end
    end
  end
end

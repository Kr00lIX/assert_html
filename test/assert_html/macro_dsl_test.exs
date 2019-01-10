defmodule AssertHTML.MacroDSLTest do
  use ExUnit.Case, async: true
  import AssertHTML.MacroDSL

  describe "(context definition)" do
    setup do
      [html: ~S{
        <p class="hard_decision">
          <a class="active link1">Yes</a>
          <a class="link2">No</a>
        </p>
    }]
    end

    test "use macro for defining context", %{html: html} do
      assert_html(html) do
        IO.inspect(html, label: "html1")
        assert_html("p") do
          assert_html |> IO.inspect(html)
          assert_html("a.link1", class: "active", text: "Yes")
          assert_html("a.link2", class: nil, text: "No")
        end
      end
    end

  #   test "use macro for defining context with selector" do
  #     html = ~S{
  #         <p id="aaa">
  #           <a class="link">Click me</a>
  #         </p>
  #     }
  #     assert_html(html, "p") do
  #       assert_html("a", class: "link", text: "Click me", id: nil)
  #     end
  #   end

  #   test "use macro for defining context with selector and attributes" do
  #     html = ~S{
  #         <p class="foo" id="descr">
  #           <a class="link">Click me</a>
  #         </p>
  #     }
  #     assert_html(html, "p", class: "foo", id: "descr") do
  #       assert_html("a", class: "link", text: "Click me", id: nil)
  #     end
  #   end

  end


end

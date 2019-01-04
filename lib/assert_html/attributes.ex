defmodule AssertHtml.Attributes do
  # use ExUnit.CaseTemplate

  @doc ~S"""
  Asserts HTML attributes in CSS selector

  ## Examples

      html = ~S{
        <form action="/ehr/action">
          <input class="control -input" type="tel" value="placeholder" />
          <button type="submit">Submit</button>
        </form>
      }
      assert_html_attributes(html, "form", action: ~r{/ehr/}) 
      assert_html_attributes(html, "form input[type=tel]", value: "placeholder", class: "control", class: "-input")
      assert_html_attributes(html, "form button", type: "submit", text: "Submit") 
  """
  # def assert_html_attributes(html, selector, attributes) do
  #   Enum.into(attributes, %{}, fn {k, v} -> {to_string(k), v} end)
  #   |> Enum.each(fn
  #     {attribute, nil} ->
  #       refute html_attribute(html, selector, attribute),
  #              "Attribute `#{attribute}` exists in `#{selector}` selector:\n #{html}"

  #     {"class", value} ->
  #       case Floki.attribute(html, selector, "class") do
  #         [style] when is_binary(style) ->
  #           for check_style <- String.split(value, " ") do
  #             assert String.contains?(style, check_style),
  #                    "Class `#{check_style}` not found in `#{style}` in `#{selector}` selector:\n #{
  #                      html
  #                    }"
  #           end

  #         _ ->
  #           assert false, "Attribute `class` not found in `#{selector}` selector:\n #{html}"
  #       end

  #     {"text", value} ->
  #       escaped_calue = value |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string()
  #       assert html_text(html, selector) == escaped_calue

  #     {attribute, %Regex{} = value} ->
  #       assert [attr_value] = Floki.attribute(html, selector, attribute),
  #              "Attribute `#{attribute}` not found in `#{selector}` selector:\n #{html}"

  #       assert attr_value =~ value

  #     {attribute, value} ->
  #       value_str = to_string(value)

  #       assert [value_str] == Floki.attribute(html, selector, attribute),
  #              "Attribute `#{attribute}` not found in `#{selector}` selector:\n #{html}"
  #   end)

  #   html
  # end

  # def html_attribute(html, selector, name) do
  #   Floki.attribute(html, selector, name)
  #   |> case do
  #     [value] -> value
  #     _ -> nil
  #   end
  # end
end

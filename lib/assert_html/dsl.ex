defmodule AssertHTML.DSL do
  @moduledoc ~S"""
  Add aditional syntax to passing current context inside block

  ### Example: pass context
  ```
  assert_html html, ".container" do
    assert_html "form", action: "/users" do
      refute_html ".flash_message"
      assert_html ".control_group" do
        assert_html "label", class: "title", text: ~r{Full name}
        assert_html "input", class: "control", type: "text"
      end
      assert_html("a", text: "Submit", class: "button")
    end
    assert_html ".user_list" do
      assert_html "li"
    end
  end
  ```

  ## Example 2: print current context for debug

  ```
  assert_html(html, ".selector") do
    IO.inspect(assert_html, label: "current context html")
  end
  ```
  """
  alias AssertHTML, as: HTML
  alias AssertHTML.Debug

  defmacro assert_html(context, selector \\ nil, attributes \\ nil, maybe_do_block \\ nil) do
    Debug.log(context: context, selector: selector, attributes: attributes, maybe_do_block: maybe_do_block)
    {args, block} = extract_block([context, selector, attributes], maybe_do_block)

    call_html_method(:assert, args, block)
    |> Debug.log_dsl()
  end

  defmacro refute_html(context, selector \\ nil, attributes \\ nil, maybe_do_block \\ nil) do
    Debug.log(context: context, selector: selector, attributes: attributes, maybe_do_block: maybe_do_block)
    {args, block} = extract_block([context, selector, attributes], maybe_do_block)

    call_html_method(:refute, args, block)
    |> Debug.log_dsl()
  end

  defp call_html_method(matcher, args, block \\ nil)

  defp call_html_method(:assert, args, nil) do
    quote do
      HTML.assert_html(unquote_splicing(args))
    end
  end

  defp call_html_method(:refute, args, nil) do
    quote do
      HTML.refute_html(unquote_splicing(args))
    end
  end

  defp call_html_method(matcher, args, block) do
    block_arg =
      quote do
        fn unquote(context_var()) ->
          unquote(Macro.prewalk(block, &postwalk/1))
        end
      end

    call_html_method(matcher, args ++ [block_arg])
  end

  # found do: block if exists
  defp extract_block(args, do: do_block) do
    {args, do_block}
  end

  defp extract_block(args, _maybe_block) do
    args
    |> Enum.reverse()
    |> Enum.reduce({[], nil}, fn
      arg, {args, block} when is_list(arg) ->
        {maybe_block, updated_arg} = Keyword.pop(arg, :do)

        {
          (updated_arg == [] && args) || [updated_arg | args],
          block || maybe_block
        }

      nil, {args, block} ->
        {args, block}

      arg, {args, block} ->
        {[arg | args], block}
    end)
  end

  # replace assert_html without arguments to context
  defp postwalk({:assert_html, env, nil}) do
    context_var(env)
  end

  defp postwalk({:assert_html, env, arguments}) do
    context = context_var(env)
    {args, block} = extract_block([context | arguments], nil)

    call_html_method(:assert, args, block)
  end

  # replace refute_html without arguments to context
  defp postwalk({:refute_html, env, nil}) do
    context_var(env)
  end

  defp postwalk({:refute_html, env, arguments}) do
    context = context_var(env)
    {args, block} = extract_block([context | arguments], nil)

    call_html_method(:refute, args, block)
  end

  defp postwalk(segment) do
    segment
  end

  defp context_var(env \\ []) do
    {:assert_html_context, env, nil}
  end
end

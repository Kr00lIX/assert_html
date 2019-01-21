defmodule AssertHTML.DSL do
  @moduledoc ~S"""
  Add aditional syntax to passing current context inside block

  ## Example 1: pass context
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

  defmacro assert_html(context, selector \\ nil, attributes \\ nil, maybe_do_block \\ nil) do
    {args, block} = extract_block([context, selector, attributes], maybe_do_block)
    result = call_html_method(:assert, args, block)
    IO.puts "\n\n~~~~>>>>>      \n#{Macro.to_string(result) } \n<<<<<  ~~\n"
    result
  end

  defmacro refute_html(context, selector \\ nil, attributes \\ nil, maybe_do_block \\ nil) do
    {args, block} = extract_block([context, selector, attributes], maybe_do_block)
    result = call_html_method(:refute, args, block)
    IO.puts "\n\n~~~~>>>>>      \n#{Macro.to_string(result) } \n<<<<<  ~~\n"
    result
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
        fn(unquote(context_var()))->
          unquote(Macro.prewalk(block, &postwalk/1))
        end
      end

    call_html_method(matcher, args ++ [block_arg])
  end

  # found do: block if exists
  defp extract_block(args, [do: do_block]) do
    {args, do_block}
  end
  defp extract_block(args, _maybe_block) do
    args
    |> Enum.reject(& &1 == nil)
    |> Enum.map_reduce(nil, fn
      arg, acc when is_list(arg) ->
        {maybe_block, updated_arg} = Keyword.pop(arg, :do)
        new_arg = if updated_arg == [], do: nil, else: updated_arg
        {new_arg, acc || maybe_block}
      arg, acc ->
        {arg, acc}
    end)
  end

  # replace assert_html without arguments to context
  def postwalk({:assert_html, env, nil}) do
    context_var(env)
  end
  def postwalk({:assert_html, env, arguments}) do
    context = context_var(env)
    {args, block} = extract_block([context | arguments], nil)

    call_html_method(:assert, args, block)
  end
  # replace refute_html without arguments to context
  def postwalk({:refute_html, env, nil}) do
    context_var(env)
  end
  def postwalk({:refute_html, env, arguments}) do
    context = context_var(env)
    {args, block} = extract_block([context | arguments], nil)

    call_html_method(:refute, args, block)
  end
  def postwalk(segment) do
    segment
  end

  def assert_html_attributes(arg1, arg2 \\ nil, arg3 \\ nil, arg4 \\ nil) do
    [arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4] |> IO.inspect(label: "call assert_html_attributes")
    if arg4 do
      arg4.(arg1)
    end
  end

  defp context_var(env \\ []) do
    {:assert_html_context, env, nil}
  end

end

defmodule AssertHTML.MacroDSL do
  # import AssertHTML

  alias AssertHTML.MacroDSL, as: DSL

  defmacro assert_html(context, selector \\ nil, attributes \\ [], maybe_do_block \\ nil) do
    [html: context, selector: selector, attributes: attributes, maybe_do_block: maybe_do_block] |> IO.inspect(label: "assert_html")

    {args, block} = extract_block([context, selector, attributes], maybe_do_block)
    result = do_assert_html(args, block)
    IO.puts "\n\n~~~~>>>>>      #{Macro.to_string(result) } \n\n"
    result
  end

  defp do_assert_html(args, nil) do
    quote do
      assert_html_attributes(unquote_splicing(args))
    end
  end
  defp do_assert_html(args, block) do
    block_arg =
      quote do
        fn(html)->
          unquote(Macro.prewalk(block, &postwalk/1))
        end
      end

    args ++ [block_arg]
  end

  # found do: block if exists
  defp extract_block(args, [do: do_block]) do
    {args, do_block}
  end
  defp extract_block(args, _maybe_block) do
    args
    |> Enum.map_reduce(nil, fn
      arg, acc when is_list(arg) ->
        {maybe_block, updated_arg} = Keyword.pop(arg, :do)
        {updated_arg, acc || maybe_block}
      arg, acc ->
        {arg, acc}
    end)
  end

  def postwalk({:assert_html, env, arguments}) do
    context = {:html, env, nil}
    updated_arguments = [context | arguments]
    {args, block} = extract_block(updated_arguments, [])

    # {args, block} |> IO.inspect(label: "updated_arguments")

    do_assert_html(args, block)
  end
  def postwalk(segment) do
    # IO.inspect(segment, label: "segment")
    segment
  end

  def assert_html_attributes(arg1, arg2 \\ nil, arg3 \\ nil, arg4 \\ nil) do
    [arg1: arg1, arg2: arg2, arg3: arg3, arg4: arg4] |> IO.inspect(label: "call assert_html_attributes")
    if arg4 do
      arg4.(arg1)
    end
  end

end

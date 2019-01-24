defmodule AssertHTML.Debug do
  @moduledoc false
  require Logger

  def log_dsl(entry, level \\ :debug, metadata \\ []) do
    if Application.get_env(:assert_html, :log_dsl) do
      Logger.log(level, fn -> "\n~~ DSL~~>>>>>      \n#{Macro.to_string(entry)} \n<<<<<  ~~\n" end, metadata)
    end

    entry
  end

  def log(entry, level \\ :debug, metadata \\ []) do
    Logger.log(level, fn -> to_iodata(entry) end, metadata)
  end

  defp to_iodata(entry) when is_binary(entry), do: entry
  defp to_iodata(entry), do: inspect(entry)
end

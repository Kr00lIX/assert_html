defmodule AssertHtml.MixProject do
  use Mix.Project

  def project do
    [
      app: :assert_html,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [ignore_warnings: ".dialyzer_ignore.exs"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, ">= 0.20.3"},

      {:dialyxir, "~> 1.0.0-rc.2", only: [:dev], runtime: false}
    ]
  end
end

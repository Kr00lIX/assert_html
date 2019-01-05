defmodule AssertHtml.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :assert_html,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # # Hex
      # description: "",
      # package: package(),

      # Docs
      name: "AssertHtml",
      docs: docs(),

      # dev
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
      {:dialyxir, "~> 1.0.0-rc.2", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.17", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "AssertHtml",
      source_ref: "v#{@version}",
      extras: ["README.md"],
      source_url: "https://github.com/Kr00lIX/assert_html"
    ]
  end
end

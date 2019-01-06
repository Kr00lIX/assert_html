defmodule AssertHtml.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :assert_html,
      version: @version,
      elixir: "~> 1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "",
      package: package(),

      # Docs
      name: "AssertHTML",
      docs: docs(),

      # Test
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.travis": :test],

      # dev
      dialyzer: [ignore_warnings: ".dialyzer_ignore.exs"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, ">= 0.20.3"},

      {:excoveralls, "~> 0.8", only: :test},

      {:dialyxir, "~> 1.0.0-rc.2", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.17", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "AssertHTML",
      source_ref: "v#{@version}",
      extras: ["README.md"],
      source_url: "https://github.com/Kr00lIX/assert_html"
    ]
  end

  # Settings for publishing in Hex package manager:
  defp package do
    %{
      package: "assert_html",
      contributors: ["Kr00lIX"],
      maintainers: ["Anatoliy Kovalchuk"],
      links: %{github: "https://github.com/Kr00lIX/assert_html"},
      licenses: ["LICENSE.md"],
      files: ~w(lib LICENSE.md mix.exs README.md)
    }
  end

end

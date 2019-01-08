defmodule AssertHTML.MixProject do
  use Mix.Project

  @version "0.0.2"
  @github_url "https://github.com/Kr00lIX/assert_html"

  def project do
    [
      app: :assert_html,
      version: @version,
      elixir: "~> 1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "ExUnit's assert helpers for testing rendered HTML backed by Floki.",
      package: package(),

      # Docs
      name: "AssertHTML",
      source_url: @github_url,
      docs: docs(),

      # Test
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.travis": :test],

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

      # Test
      {:excoveralls, "~> 0.8", only: :test},
      {:junit_formatter, "~> 2.1", only: :test},
      {:credo, "~> 0.8", only: [:dev, :test]},

      # Dev
      {:dialyxir, "~> 1.0.0-rc.4", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "AssertHTML",
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md"],
      source_url: @github_url,
      deps: [Floki: "https://hexdocs.pm/floki/Floki.html"]
    ]
  end

  # Settings for publishing in Hex package manager:
  defp package do
    %{
      package: "assert_html",
      contributors: ["Kr00lIX"],
      maintainers: ["Anatoliy Kovalchuk"],
      links: %{"GitHub" => @github_url},
      licenses: ["LICENSE.md"],
      files: ~w(lib LICENSE.md mix.exs README.md CHANGELOG.md)
    }
  end
end

defmodule AssertHTML.MixProject do
  use Mix.Project

  @version "0.0.4"
  @github_url "https://github.com/Kr00lIX/assert_html"

  def project do
    [
      app: :assert_html,
      version: @version,
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
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
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],

      # dev
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true,
        remove_defaults: [:unknown]
      ]
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
      {:floki, "~> 0.21"},

      # Test
      {:excoveralls, "~> 0.10", only: :test},
      {:junit_formatter, "~> 3.0", only: :test},
      {:credo, "~> 1.0", only: [:dev, :test]},

      # Dev
      {:dialyxir, "~> 1.0.0-rc.6", only: :dev, runtime: false},
      {:ex_doc, "~> 0.20", only: :dev, runtime: false}
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
      name: "assert_html",
      contributors: ["Kr00lIX"],
      maintainers: ["Anatoliy Kovalchuk"],
      links: %{"GitHub" => @github_url},
      licenses: ["MIT"],
      files: ~w(lib LICENSE.md mix.exs README.md CHANGELOG.md),
    }
  end
end

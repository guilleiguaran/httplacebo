defmodule Httplacebo.Mixfile do
  use Mix.Project

  @description "The 'do nothing' HTTP client for Elixir."

  def project do
    [app: :httplacebo,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     name: "HTTPlacebo",
     description: @description,
     package: package,
     deps: deps,
     source_url: "https://github.com/guilleiguaran/httplacebo"]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: []]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    []
  end

  defp package do
    [ maintainers: ["Guillermo Iguaran"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/guilleiguaran/httplacebo"} ]
  end
end

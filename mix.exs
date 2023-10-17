defmodule SQLParser.MixProject do
  use Mix.Project

  @repository "https://github.com/Byzanteam/sql-parser"

  def project do
    [
      app: :sql_parser,
      repository: @repository,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, ">= 0.0.0", optional: true},
      {:rustler_precompiled, "~> 0.7.0"}
    ]
  end
end

defmodule Dbg.MixProject do
  use Mix.Project

  def project do
    [
      app: :dbg_inspect,
      version: "0.1.0",
      elixir: "~> 1.7",
      description: "dbg_inspect provides an extended version of `IO.inspect/1` function for the debug purposes.",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def package do
    [
      contributors: ["Roman Smirnov"],
      maintainers: ["Roman Smirnov"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/romul/dbg_inspect"}
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end
end

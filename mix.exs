defmodule Dictum.Mixfile do
  use Mix.Project

  def project do
    [app: :dictum,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger],
     mod: {Dictum, []}]
  end

  defp deps do
    [
      {:benchfella, "~> 0.2.0"},
    ]
  end
end

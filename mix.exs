defmodule Dumbo.Nif.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :dumbo_nif,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:rustler, "~> 0.38", runtime: false, optional: true},
      {:dumbo, "~> 0.3", only: :test},
      {:rustler_precompiled, "~> 0.9"}
    ]
  end
end

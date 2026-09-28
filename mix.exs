defmodule Dumbo.Nif.MixProject do
  use Mix.Project

  def project do
    [
      app: :dumbo_nif,
      version: "0.1.0",
      elixir: "~> 1.20",
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
      {:rustler, "~> 0.38", runtime: false},
      {:dumbo, "~> 0.3", only: :test}
    ]
  end
end

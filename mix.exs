defmodule Dumbo.Nif.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :dumbo_nif,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # package
      name: "Dumbo",
      source_url: "https://github.com/byhemechi/dumbo_nif",
      package: package(),
      docs: docs(),
      description: "Native implementation of some Dumbo internals"
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
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:rustler, "~> 0.38", runtime: false, optional: true},
      {:dumbo, "~> 0.3", only: :test},
      {:rustler_precompiled, "~> 0.9"}
    ]
  end

  defp docs do
    [
      main: "Dumbo.Nif"
    ]
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/byhemechi/dumbo_nif"},
      files: [
        "lib",
        "native/dumbo_nif/.cargo",
        "native/dumbo_nif/src",
        "native/dumbo_nif/Cargo*",
        "checksum-*.exs",
        "mix.exs"
      ]
    ]
  end
end

defmodule Ccs811.MixProject do
  use Mix.Project

  @source_url "https://github.com/Efesto/ccs811"
  @version "0.1.0"

  def project do
    [
      app: :ccs811,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: description(),
      docs: docs(),
      package: package(),
    ]
  end

  def application do
    [
      mod: {Ccs811.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Driver for CCS811 Ultra-Low Power Digital Gas Sensor for Monitoring Indoor Air Quality"
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
    ]
  end

  defp deps do
    [
      {:circuits_i2c, "~> 0.3.7"},
      {:telemetry_poller, "~> 0.5"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  defp package() do
    [
      name: "ccs811",
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Ccs811 Datasheet" =>
          "https://cdn.sparkfun.com/assets/learn_tutorials/1/4/3/CCS811_Datasheet-DS000459.pdf",
      }
    ]
  end
end

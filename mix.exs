defmodule AntWorld.Mixfile do
  use Mix.Project

  def project do
    [app: :ant_world,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib"],
     compilers: Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {AntWorld, []},
     applications: [:cauldron, :logger]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [
      {:cauldron, "0.1.5"},
      {:json,   "~> 0.3.0"}
    ]
  end
end

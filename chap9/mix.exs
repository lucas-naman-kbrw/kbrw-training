defmodule Chap9.MixProject do
  use Mix.Project

  def project do
    [
      app: :chap9,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger,:ewebmachine,:cowboy], mod: {Chap9,[]}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ewebmachine, "2.2.1"}, 
      {:cowboy, "~> 1.0"},
      {:plug_cowboy, "~> 1.0"}
    ]
  end
end

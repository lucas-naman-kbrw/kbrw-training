defmodule ChapThree.MixProject do
  use Mix.Project

  def project do
    [
      app: :chap_three,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:reaxt_webpack] ++ Mix.compilers
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :reaxt],
      mod: {ChapThree, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ewebmachine, "2.2.1"}, 
      {:cowboy, "~> 1.0"},
      {:plug_cowboy, "~> 1.0"},
      {:poison, "~> 2.1.0"},
      {:reaxt, "~> 2.1.0", github: "kbrw/reaxt", tag: "2.1.0"},
    ]
  end
end

defmodule ChapThree do

  def start(_type, _args) do
    import Supervisor.Spec

    Server.Supervisor.start_link
    JsonLoader.load_to_database("", "orders_dump/orders_chunk1.json")
    children = [
      # Define workers and child supervisors to be supervised
      Plug.Adapters.Cowboy.child_spec(:http, Server.Router, [], [port: 4001])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end

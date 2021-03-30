# defmodule ChapThree do

#   def start(_type, _args) do
#     import Supervisor.Spec

#     Server.Supervisor.start_link
#     JsonLoader.load_to_database("", "orders_dump/orders_chunk0.json")
#     children = [
#       # Define workers and child supervisors to be supervised
#       {Plug.Cowboy, scheme: :http, plug: Server.Router, options: [port: 4001]}
#     ]

#     # See https://hexdocs.pm/elixir/Supervisor.html
#     # for other strategies and supported options
#     opts = [strategy: :one_for_one]
#     Supervisor.start_link(children, opts)
#     Application.put_env(
#       :reaxt,:global_config,
#       Map.merge(
#         Application.get_env(:reaxt,:global_config), %{localhost: "http://localhost:4001"}
#       )
#     )
#     Reaxt.reload
#   end
# end


defmodule ChapThree do
  use Application
  def start(_type, _args) do
      Server.Supervisor.start_link
      JsonLoader.load_to_database("", "orders_dump/orders_chunk0.json")
      Supervisor.start_link([
        Plug.Adapters.Cowboy.child_spec(:http,Server.EwebRouter,[], port: 4000)      ], strategy: :one_for_one)

      Application.put_env(
        :reaxt,:global_config,
        Map.merge(
          Application.get_env(:reaxt,:global_config), %{localhost: "http://localhost:4001"}
        )
      )
      Reaxt.reload
  
  end

end
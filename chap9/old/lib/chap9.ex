defmodule Chap9 do
  use Application
  def start(_type, _args), do:    Supervisor.start_link([
        Plug.Adapters.Cowboy.child_spec(:http,Server.EwebRouter,[], port: 4000)      ], strategy: :one_for_one)

end

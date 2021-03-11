defmodule Server.Router do
  use Plug.Router

  plug(:match)

  plug Plug.Static, from: "priv/static", at: "/static"
  plug(:dispatch)

  get "/api/orders" do
    IO.puts "api/orders"
    body = Poison.encode!(Enum.map(Server.Database.get_table, fn {_key, map}-> map end))
    send_resp(conn, 200, body)
  end

  get "/api/order/:id" do
    IO.puts "api/order/:id"
    {_id, map} = hd(Server.Database.get_row(id))
    body = Poison.encode!(map)
    send_resp(conn, 200, body)
  end

  get _, do: send_file(conn, 200, "priv/static/index.html")

end

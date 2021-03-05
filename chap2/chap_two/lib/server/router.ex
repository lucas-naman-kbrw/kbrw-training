defmodule Server.Router do
  use Plug.Router

  plug(:match)
  plug Plug.Parsers, parsers: [:json],
                     pass:  ["application/json"],
                     json_decoder: Poison
  plug(:dispatch)



  get "/row/:id" do
    {_id, map} = hd(Server.Database.get_row(id))
    body = Poison.encode!(map)
    send_resp(conn, 200, body)
  end

  get "/rows" do
    body = Poison.encode!(Enum.map(Server.Database.get_table, fn {_key, map}-> map end))
    send_resp(conn, 200, body)
  end

  get "/search" do
    fields =
      conn.query_string
      |> String.split("&")
      |> Enum.map(fn x -> List.to_tuple(String.split(x, "=")) end)
    IO.inspect fields
    body = Poison.encode!(Server.Database.search("", fields))
    IO.inspect body
    send_resp(conn, 200, body)
  end

  post "/row/:id" do
    Server.Database.insert_row({id, conn.body_params})
    send_resp(conn, 200, "Post row!")
  end

  put "/row/:id" do
    Server.Database.insert_row({id, conn.body_params})
    send_resp(conn, 200, "Put row!")
  end

  delete "/row/:id" do
    Server.Database.delete_row({id, 5})
    send_resp(conn, 200, "Delete row!")
  end

  match _, do: send_resp(conn, 404, "Page Not Found")

end

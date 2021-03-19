defmodule Server.Router do
  use Plug.Router

  plug(:match)

  plug Plug.Static, at: "/public", from: :chap_three

  plug(:dispatch)

  require EEx
  EEx.function_from_file :defp, :layout, "web/layout.html.eex", [:render]

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

  delete "/api/order/:id" do
    IO.puts("delete " <> id)
    Process.sleep(1000)
    Server.Database.delete_row({id, ""})
    body = Poison.encode!(%{"ok" => "ok"})
    send_resp(conn, 200, body)
  end

  get _ do
    conn = fetch_query_params(conn)
    render = Reaxt.render!(:app, %{path: conn.request_path, cookies: conn.cookies, query: conn.params},30_000)
    send_resp(put_resp_header(conn,"content-type","text/html;charset=utf-8"), render.param || 200,layout(render))
  end

end

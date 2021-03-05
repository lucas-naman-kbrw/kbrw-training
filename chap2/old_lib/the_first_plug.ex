defmodule TheFirstPlug do
  import Plug.Conn

  def init(options) do
    # initialize options
    options
  end

  def call(conn, opts) do
    {sc, msg} =
      case conn.path_info do
        ["me"]->
          {200, "I am The First, The One, Le Geant Plug Vert, Le Grand Plug, Le Plug Cosmique."}
        [] ->
          {200, "Welcome to the new world of Plugs!"}
        _ ->
          {404, "Go away, you are not welcome here."}
      end

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(sc, msg)
  end
end

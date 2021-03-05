defmodule Server.TheCreator do

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Server.TheCreator

      @error {404, "Get out or smthg"}

      @routes %{}

      @before_compile Server.TheCreator

    end
  end

  defmacro __before_compile__(_env) do
    quote do

      import Plug.Conn

      def init(options) do
        # initialize options
        Server.Supervisor.start_link
        options
      end

      def call(conn, opts) do
        path = conn.request_path
        {sc, msg} =
          if Map.has_key?(@routes, path) do
            Map.get(@routes, path)
          else
            @error
          end

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(sc, msg)
      end

    end
  end

  defmacro my_error(arg) do
    quote do
      args = unquote(arg)
      @error {args[:code], args[:content]}
    end
  end

  defmacro my_get(route, do: block) do
    quote do
      @routes Map.put(@routes, unquote(route), unquote(block))
    end
  end

end

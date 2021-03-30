defmodule MyJSONApi do 
  use Ewebmachine.Builder.Handlers

  plug :cors
  plug :add_handlers, init: %{}

  content_types_provided do: ["application/json": :to_json]
  defh to_json, do: Poison.encode!(state[:json_obj])

  defp cors(conn,_), do: 
    put_resp_header(conn,"Access-Control-Allow-Origin","*")
end

defmodule ErrorRoutes do
  use Ewebmachine.Builder.Resources ; resources_plugs
  resource "/error/:status" do %{s: elem(Integer.parse(status),0)} after 
    content_types_provided do: ['text/html': :to_html, 'application/json': :to_json]
    defh to_html, do: "<h1> Error ! : '#{Ewebmachine.Core.Utils.http_label(state.s)}'</h1>"
    defh to_json, do: ~s/{"error": #{state.s}, "label": "#{Ewebmachine.Core.Utils.http_label(state.s)}"}/
    finish_request do: {:halt,state.s}
  end
end

defmodule Server.EwebRouter do
    use Ewebmachine.Builder.Resources

    if Mix.env == :dev, do: plug Ewebmachine.Plug.Debug
    resources_plugs error_forwarding: "/error/:status", nomatch_404: true
    plug ErrorRoutes
    plug :resource_match
    plug Ewebmachine.Plug.Run
    plug Ewebmachine.Plug.Send

    resource "/hello/:name" do %{name: name} after
        content_types_provided do: ['text/html': :to_html]
        defh to_html, do: "<html><h1>Hello #{state.name}</h1></html>"
    end

    resource "/public/*path" do %{path: Enum.join(path,"/")} after
        resource_exists do
            File.regular?(path state.path)
        end
        content_types_provided do:
            [{state.path|>Plug.MIME.path|>default_plain,:to_content}]
        defh to_content, do:
            File.stream!(path(state.path),[],300_000_000)
        defp path(relative) do
            "priv/static/#{relative}"
        end
        defp default_plain("application/octet-stream"), do: "text/plain"
        defp default_plain(type), do: type
    end

    resource "/api/orders" do %{} after
        content_types_provided do: ['application/json': :to_json]
        defh to_json do 
            Poison.encode!(Enum.map(Server.Database.get_table, fn {_key, map}-> map end))
        end
    end

    resource "/api/order/:id" do %{id: id} after
        allowed_methods do: ["DELETE"]
        delete_resource do: Server.Database.delete_row({state.id, ""})
    end

    resource "/*_" do %{} after 
        require EEx
        EEx.function_from_file :defp, :layout, "web/layout.html.eex", [:render]
        content_types_provided do: ['text/html': :to_html]
        defh to_html do 
            conn = fetch_query_params(conn)
            layout(Reaxt.render!(:app,%{path: conn.request_path, cookies: conn.cookies, query: conn.params},30_000))
        end
    end

end
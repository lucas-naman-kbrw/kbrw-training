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


    resource "/static/*path" do %{path: Enum.join(path,"/")} after
        resource_exists do:
        File.regular?(path state.path)
        content_types_provided do:
        [{state.path|>Plug.MIME.path|>default_plain,:to_content}]
        defh to_content, do:
        File.stream!(path(state.path),[],300_000_000)
        defp path(relative), do: "#{:code.priv_dir :ewebmachine_example}/web/#{relative}"
        defp default_plain("application/octet-stream"), do: "text/plain"
        defp default_plain(type), do: type
    end

end
# Chapter 9 - EWebMachine

[**EWebMachine**](https://github.com/kbrw/ewebmachine) is an **Elixir module** that allows you to design the **routing** of your HTTP server using a **decision tree**.  
  
## Step 0 - Introduction to EWebMachine 

The module is available on [Github](https://github.com/kbrw/ewebmachine).  
  
_**Ewebmachine** is a full rewrite with clean DSL and plug integration based on [****Webmachine****](https://github.com/webmachine/webmachine) from basho._  
  
The objective of **Ewebmachine** is to provide an FSM that allows you to manage the requests made to our **HTTP** API more easily.  
Here is the HTTP state tree:  

![Webmachine-FSM](./img/Webmachine-FSM.png)

As yo can see on the previous schema, when a request is performed to the server, the information of this connection will go through the FSM and will be associated with a return code and a content result.  
With **Ewebmachine**, you can modify some states of the FSM to easily adapt the standard **REST API** to your need.  
  
Let's dive into the **Ewebmachine** code and have a look to the example provided on the Github:  
  
We can observe that the architecture of the code is divided in multiple module where each module represent either a **Handler**, a **Resource** or the **API**.  
Thus, we will describe each module independently.  
To understand the following paragraph, you will need to open the source in the folder `deps/ewebmachine/lib`.

### Handlers

``` elixir 
defmodule MyJSONApi do 
  use Ewebmachine.Builder.Handlers
  plug :cors
  plug :add_handlers, init: %{}

  content_types_provided do: ["application/json": :to_json]
  defh to_json, do: Poison.encode!(state[:json_obj])

  defp cors(conn,_), do: 
    put_resp_header(conn,"Access-Control-Allow-Origin","*")
end
```
_As we can see, this module is a **`Builder.Handlers`** module._  
  
First, with `plug :cors` we are using the default **`Plug`** module as described in the [second chapter](chapt2.html): this way we reference the `:cors` function to be executed before every other `plug` in our module.  
  
Now let's have a look into the library in the file, `builder.handlers.ex`. This file implements the default handlers and add the possibility to create custom handlers: you will need to use the `plug :add_handlers` defined in the **`Ewebmachine.Builder.Handlers`**:  
  * This function replace the state of the connection by the parameters provided as `:init` (here `%{}`). 
  * It then put all the resources_handlers we defined (or the default ones) into a private property of the `conn`.
  * To define a custom handler, we can use the macro `defh` (cf source).  

  
Last, let's understand what the `handler_quote` private function do when called in `defh`:  
  * It adds the referenced handler to the map `@resource_handlers`
  * It defines the function of the name of your macro (here `to_json`), and wrap the response to return when it will be called by **`Plug`**.

  
To conclude, this add all the default handlers **plus** your custom handlers to our **`Ewebmachine.Builder.Handlers`** module.  
  
*All the default handlers are defined in the file `handlers.ex`, so if you need to see the expected output of an handler, ...*  
  
### Resources
    
``` elixir 
defmodule ErrorRoutes do
  use Ewebmachine.Builder.Resources ; resources_plugs
  resource "/error/:status" do %{s: elem(Integer.parse(status),0)} after 
    content_types_provided do: ['text/html': :to_html, 'application/json': :to_json]
    defh to_html, do: "<h1> Error ! : '#{Ewebmachine.Core.Utils.http_label(state.s)}'</h1>"
    defh to_json, do: ~s/{"error": #{state.s}, "label": "#{Ewebmachine.Core.Utils.http_label(state.s)}"}/
    finish_request do: {:halt,state.s}
  end
end
```
Let's now have a look into the **`Ewebmachine.Builder.Resources`** module.  
As we can see in the previous code, the module defines 2 macros `resources_plugs` and `resource`.  
The **`Ewebmachine.Builder.Resources`** can take parameters when it is called using `use`.  

  * `resources_plugs` allows to modify the behavior of the module with some option. Here we use the default behavior. The default behavior add the following plug: 
    * `:resource_match`
    * `Ewebmachine.Plug.Run` 
    * `Ewebmachine.Plug.Send` 
  * `resource` create a new module named from the caller module and the route given (`route_as_mod/1`).
    * This module contains a **`Ewebmachine.Builder.Handlers`** module.
    * The `do:` block of your resource macro is added in the `:wm_routes` attribute your module. These routes are used in the `__before_compile__` to define the `Plug.Router.match` function associated with the routes.
    * The `:after` block is unquoted as the body of the new module (so it behave as described before for the **`MyJSONAPI`** module.

  
_More examples:_  
``` elixir 
defmodule FullApi do
  use Ewebmachine.Builder.Resources
  if Mix.env == :dev, do: plug Ewebmachine.Plug.Debug
  resources_plugs error_forwarding: "/error/:status", nomatch_404: true
  plug ErrorRoutes

  resource "/hello/:name" do %{name: name} after 
    content_types_provided do: ['application/xml': :to_xml]
    defh to_xml, do: "<Person><name>#{state.name}</name>"
  end

  resource "/hello/json/:name" do %{name: name} after 
    plug MyJSONApi #this is also a plug pipeline
    allowed_methods do: ["GET","DELETE"]
    resource_exists do: pass((user=DB.get(state.name)) !== nil, json_obj: user)
    delete_resource do: DB.delete(state.name)
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
```
  
**Go and look inside the source code of EWebMachine to fully understand the processes behind the use of the macros like `resource`, etc.**  
  * `core.ex`: In this file you will find the entry point of the **Ewebmachine**'s FSM. All the transition of the FSM are defined with the macro `decision` which is defined in the module **`Ewebmachine.Core.DSL`**.
  * `core.dsl.ex`: As you see, the `decision` macro only verify that the signature have 2 parameters and before executing the body of the macro in the function of the same name, will execute this code which will modify `conn` contained variable by the content of the `Ewebmachine.Log.debug_decision` return: 
``` elixir 
unquote(conn) = Ewebmachine.Log.debug_decision(unquote(conn), unquote(name))
```
  * `plug.run.ex`: You will find the `call/2` that call the entry point of the FSM `v3/2`. As seen before, the module **`Plug.Run`** is provided as a `plug`.
  * `plug.send.ex`: this module implements a plug used to create the answer for the client and send it.

# Step 1 - Hello World with EwebMachine

Now that you understand how **EwebMachine** works, let's setup a quick server on the port `4002` that will return an hello page to the user.

``` elixir 
defmodule Server.EwebRouter do
  use Ewebmachine.Builder.Resources
  plug :resource_match
  plug Ewebmachine.Plug.Run
  plug Ewebmachine.Plug.Send
  resource "/hello/:name" do %{name: name} after
    content_types_provided do: ['text/html': :to_html]
    defh to_html, do: "<html><h1>Hello #{state.name}</h1></html>"
  end
end
```
As we have seen in the source, we need to call the different plugs `:resource_match`, 
**`Ewebmachine.Plug.Run`** and **`Ewebmachine.Plug.Send`** manually if they are not called in the 
injected source.  
Then we need to define our resource. Here, it is the `Hello World!` resource defined the same way as
the **`MyJSONApi`** in the library example.  
Now we will add some debug feature when we are in development mode: 
``` elixir 
defmodule Server.EwebRouter do
use Ewebmachine.Builder.Resources
if Mix.env == :dev, do: plug Ewebmachine.Plug.Debug
[...]
```
  
_You can check if the debug is activated by calling in your `iex` the function `Mix.env/0`._  
  
Running your program, ou should have at the address `http://localhost:<your_port>/wm_debug` the list of **all** the queries 
you have done to your **`Ewebmachine`** module. This is really useful when we need to debug our web app.  
  
If we add to our project a little error handling we will have a complete version of our first **`Ewebmachine`** module.
``` elixir 
resources_plugs error_forwarding: "/error/:status", nomatch_404: true
```
  
The `resource_plugs` macro provides to our module the 3 required `plug` to make the module work:
* `:resource_match`
* **`Ewebmachine.Plug.Send`**
* **`Ewebmachine.Plug.Send`**

_If you want to learn more about Error Handling, go take a look to the files `plug.error_as_*.ex`._  

# Step 2 - Put Reaxt and our API on the Ewebmachine module

---
**Exercise:**
  * Inspiring yourself from the previous provided code, change your **Router** module to now use **EWebmachine** instead of **Plug.Router**
---
## Question time !

* What is a **decision tree** ?
* Why use **EWebaMachine** instead of **Plug.Router** ?
* What does **DSL** stands for ?

---
[Prev Chapter](chap8.html) **Chapter 9** [Next Chapter](chap10.html)

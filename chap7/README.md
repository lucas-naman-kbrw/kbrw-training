# Chapter 7 - Reaxt

[**`Reaxt`**](https://github.com/kbrw/reaxt) is a home-made `elixir` module. The objective of this module is to render our pages on our server, allowing users with unactivated Javascript to access our website. **Reaxt** run a **NodeJS** server that will generate the **HTML** pages, using **React**. These generated pages are returned to the user on its browser.  
This divides our Javascript execution in two:
  * a **server side** 
  * a **client side**

## Step 0 - [Port](https://hexdocs.pm/elixir/Port.html) and [Node_Erlastic](https://github.com/kbrw/node_erlastic)

This step aims to introduce you to the `Port` Elixir library, that allows **Reaxt** to communicate to a **NodeJS** server.  
To help us, we're gonna use our home-made library **node_erlastic**.  
  
**Go read the documentation of both this libraries.**  

### Hello [Port](https://hexdocs.pm/elixir/Port.html) !

Create a new `Mix` project:
```sh
  $> mix new hello_port --module HelloPort
```
  
Our `HelloPort` module is gonna be a really simple `GenServer`.  
Our init function will contain something like this:
```elixir
port = Port.open({:spawn, '#{cmd}'}, [:binary, :exit_status, packet: 4] ++ opts)
```
  * `Port` allow us to `:spawn` a new OS process, and talk to it
    * Here, it will spawn the OS process using the `cmd` parameter
      * _Example: "node test.js" will spawn a node server using the script test.js_
    * I will let you check the meaning of the options
  * We bind it to `port`, that will be our internal GenServer state 
  
To communicate with our `NodeJS` server, we're gonna send it **binary data**. To achieve that, we will use the `:erlang.term_to_binary/1` function.  
  
Here is how we're gonna send data to our `node_erlastic` server:  
```elixir
  send(port, {self, {:command, :erlang.term_to_binary(term)}})
``` 
  * `port` is our GenServer internal state
  * `:command` is used to tell our `node_erlastic` that we're sending it a command
  * the `term` is our real command
    * _Example: `GenServer.cast HelloPort, {:my_command, 42`}_
      * Here `{:my_command, 42}` is our `term`
  
We will also need to receive data, especially for our `handle_call/3` function. To achieve that, we will use the `receive` function.  
**I will not show you how to do it, take a look at [node_erlastic](https://github.com/kbrw/node_erlastic) and the [Kernel documentation](https://hexdocs.pm/elixir/Kernel.html).**  
    
We should be able to create our `GenServer` using this syntax:   
```elixir
GenServer.start_link(HelloPort, {"node hello.js", 0, cd: "/path/to/proj"}, name: Hello)
```  
---
**Exercice:**  
  * Using the [node_erlastic](https://github.com/kbrw/node_erlastic) documentation, create a file named `hello.js` that will allow us to perform some actions from our `HelloPort` GenServer
    * When sending **call** with the command `:hello` the **node server** should answer `Hello world!`. You `call` will return this message.
  * Invent other use cases for the `cast` and `call`, have some fun !

![hello_port](./img/hello_port.png)

---
## Step 1 - Install Reaxt dependencies 

**Reaxt** works exactly like what you did in the previous step.  
  
**There is no magic !**

### Mix dependencies 

First, let's install **`Reaxt`** dependencies in our **mix** project. 

``` elixir
def project do 
  [
    ...,
    compilers: [:reaxt_webpack] ++ Mix.compilers
  ]
end 

defp deps do
  [
    {:reaxt, "~> 2.0", github: "kbrw/reaxt"}, 
    ...
  ]
end
```

And launch its application 

``` elixir 
def application do                                                            
  [
    applications: [..., :reaxt],
    ...
  ]
end
```

### Web server

Now we have to install our **server side** js in our `web/` directory.      
First, we will install the `npm` dependencies required by `Reaxt`. For that, we will need to make a special `tar` package for npm.

```sh 
cd ./deps/reaxt/priv/
tar -czf reaxt.tgz commonjs_reaxt/
mv reaxt.tgz ../../../web
cd ../../../web
npm install reaxt.tgz --save-dev 
```

All this is already done by the mix task in `reaxt/lib/tasks.ex` (**I recommend you to read this file**).

``` elixir 
mix npm.install 
```

The server side now needs `webpack` as a dependency. So, we need to move it from `devDependencies` to `dependencies` (if it's not already the case).  

## Step 1 - Configure the build

Now that we have all the dependencies, we will need to configure `reaxt`, using the file `config.exs`.  
**I recommand you to have a look at `reaxt` source in `deps/reaxt`.**  
  
Let's update our `config/config.exs` file: 

``` elixir
config :reaxt, [
  otp_app: :tutokbrwstack,
  hot: false,
  pool_size: 3,
  global_config: %{}
]
```

In this configuration:  
  * `hot` means hot reload (a script that will reload your page if you do some modification on it). If you want to activate it, you set this option to true and generate `webpack/client.js`
  * `pool_size` represent the number of **`GenServer`** started by [`:poolboy`](https://elixirschool.com/en/lessons/libraries/poolboy/)
  * `global_config` is the **Reaxt** general configuration 
  
Now, we need to provide a rule to compile the server side of our application.  
Thus, we will need to update our `webpack.config.js` file.  
The configuration now needs to be splited between the **client** and the **server** side configurations.  
  
The `module.exports` configuration became the `client_config` variable:

```js 
var client_config = {
  devtool: 'source-map',
  //>>> entry: './app.js',
  entry: "reaxt/client_entry_addition",
  //>>> output: { filename: 'bundle.js' , path: path.join(__dirname, '../priv/static' ) }, 
  output: { 
    filename: 'client.[hash].js', 
    path: path.join(__dirname, '../priv/static' ),
    publicPath: '/public/'
  }, 
  plugins: [
    new ExtractTextPlugin({filename: "styles.css"}),new webpack.IgnorePlugin(/vertx/)
  ],
  module: { ... }
}
```

If you have the `babel` version set 6 in your dependencies you will need to add `exclude: /node_modules/` as option in your `module` value. This will prevent babel to load all the javascript file 
in you node module folder and to transpile them in your `server.js`.  
  
And we create the server configuration which will be used by our node server:  
```js 
var server_config = Object.assign(Object.assign({},client_config),{
 target: "node",
 entry: "reaxt/react_server",
 output: {
   path: path.join(__dirname, '../priv/react_servers'), //typical output on the default directory served by Plug.Static
   filename: 'server.js' //dynamic name for long term caching, or code splitting, use WebPack.file_of(:main) to get it
 },
})
```

Finally we need to export the module as done in the previous `webpack.config.js` file :

```js
module.exports = [client_config,server_config]
```
And move our `app.js` in a sub directory named `components`, as well as update the paths to your css in your `app.js`.  
  
Now compile your server with 
```sh
mix webpack.compile
```
  
_**If you don't understand some part of this configuration, go read the documentation of Reaxt on [Github](https://github.com/kbrw/reaxt).**_

## Step 2 - Script modification

### Our Elixir app
Let's now update our main application function to set the correct 
environment for **`Reaxt`**.  
  
``` elixir 
defmodule TutoKBRWStack do 
  def start(_, _) do 
    ...
    Application.put_env(
      :reaxt,:global_config,
      Map.merge(
        Application.get_env(:reaxt,:global_config), %{localhost: "http://localhost:4001"}
      )
    )
    Reaxt.reload
    ...
  end
end 
```

This scripts provide to **`Reaxt`** its working environment and also put a callback on the URL in case the website get some modifications: this will automatically reload your browser once some modification have been done on your front.  
  
### Our JS app

We need to submit 2 different execution flow depending on the side the code is being executed (server / client).    
If the execution is occuring on the server side, we will download the `remoteProps`, but we won't render the server.  
Whereas on the client side, we need to render the objects. 
  
To isolate the two flows, we have to export two functions that **Reaxt** will use. Let's add them to our `app.js`:
```js 
module.exports = {
  reaxt_server_render(params, render){
    inferPropsChange(params.path, params.query, params.cookies)
      .then(()=>{
        render(<Child {...browserState}/>)
      },(err)=>{
        render(<ErrorPage message={"Not Found :" + err.url } code={err.http_code}/>, err.http_code)
      })
  },
  reaxt_client_render(initialProps, render){
    browserState = initialProps
    Link.renderFunc = render
    window.addEventListener("popstate", ()=>{ Link.onPathChange() })
    Link.onPathChange()
  }
}
```
  * `reaxt_server_render` will be called in our `server.js`
  * `reaxt_client_render` will be called in our `client.js`
  * The `Link` object is a new **React Class** that we are gonna create
    * Its job is to handle all things relative to links
      * change of paths (our `onPathChange`), navigation (our `GoTo`), etc.
  * the `inferPropsChange` contains all the previous code that was in `onPatchChange` that concerns the **remote props**.

#### inferPropsChange

Let's first attack by our new `inferPropsChange` function.  
  
```js
var browserState = {}

function inferPropsChange(path,query,cookies){ // the second part of the onPathChange function have been moved here
  browserState = {
    ...browserState,
    path: path, qs: query,
    Link: Link,
    Child: Child
  }

  var route, routeProps
  for(var key in routes) {
    routeProps = routes[key].match(path, query)
    if(routeProps){
      route = key
      break
    }
  }

  if(!route){
    return new Promise( (res,reject) => reject({http_code: 404}))
  }
  browserState = {
    ...browserState,
    ...routeProps,
    route: route
  }

  return addRemoteProps(browserState).then(
    (props)=>{
      browserState = props
    })
}
```
This is pretty straight forward, no need to explain the code. If you don't understand it, I suggest you go back to [chapter 5](./chap5.html).  

#### Our new Link class

The `Link` class handles everything related to our pages navigation and window URL.  
Let's move our `onPathChange` and `GoTo` functions into it:  
```js
var Link = createReactClass({
  statics: {
    renderFunc: null, //render function to use (differently set depending if we are server sided or client sided)
    GoTo(route, params, query){// function used to change the path of our browser
      var path = routes[route].path(params)
      var qs = Qs.stringify(query)
      var url = path + (qs == '' ? '' : '?' + qs)
      history.pushState({},"",url)
      Link.onPathChange()
    },
    onPathChange(){ //Updated onPathChange
      var path = location.pathname
      var qs = Qs.parse(location.search.slice(1))
      var cookies = Cookie.parse(document.cookie)
      inferPropsChange(path, qs, cookies).then( //inferPropsChange download the new props if the url query changed as done previously
        ()=>{
          Link.renderFunc(<Child {...browserState}/>) //if we are on server side we render 
        },({http_code})=>{
          Link.renderFunc(<ErrorPage message={"Not Found"} code={http_code}/>, http_code) //idem
        }
      )
    },
    LinkTo: (route,params,query)=> {
      var qs = Qs.stringify(query)
      return routes[route].path(params) +((qs=='') ? '' : ('?'+qs))
    }
  }
})
```
  * Both `onPatchChange` and `GoTo` should be familiar to you
  * `LinkTo` is used to return the expected URL, like in `GoTo` except it returns it instead of pushing it to the browser

Some browsers do not support **Javascript**, or block it. To fix that, we will render all our links using the `render` function of our **Link** Class:  
```js
onClick(ev) {
    ev.preventDefault();
    Link.GoTo(this.props.to,this.props.params,this.props.query);
  },
  render (){//render a <Link> this way transform link into href path which allows on browser without javascript to work perfectly on the website
    return (
      <a href={Link.LinkTo(this.props.to,this.props.params,this.props.query)} onClick={this.onClick}>
        {this.props.children}
      </a>
    )
  }
```

#### Handle the localhost property

Our server endpoint is different if we are on the client or on the server.  
  
Let's change the HTTP function to work on the server side: 
```js 
var localhost = require('reaxt/config').localhost
var XMLHttpRequest = require("xhr2") // External XmlHTTPReq on browser, xhr2 on server
var HTTP = new (function(){
    [...]
  this.req = (method,url,data)=>{
    return new Promise((resolve, reject) => {
      var req = new XMLHttpRequest()
      url = (typeof window !== 'undefined') ? url : localhost+url

    [...]
```
Here, the API address is furnished to the script when it is running on the server: the relative path doesn't work on the server side. 

## Step 3 - Change our index.html to layout.html.eex

In our new **Webpack** configuration our generated `client.js` contains a hash in his name.  
To help us face that, we will generate our `index.html` file via **Reaxt**.  
  
**We will use the [**`EEx`**](https://hexdocs.pm/eex/EEx.html#function_from_file/5) module.**  
  

  * Copy the `layout.html.eex` into your web directory. 
  * In your **`Router`** module, change your `Plug.Static`
``` elixir 
plug Plug.Static, at: "/public", from: :tutokbrwstack
```
and add
``` elixir 
require EEx
EEx.function_from_file :defp, :layout, "web/layout.html.eex", [:render]
```
  
Finally, we need to return the generated code from **`Reaxt`** to the client.  
``` elixir 
  get _ do
    conn = fetch_query_params(conn)
    render = Reaxt.render!(:app, %{path: conn.request_path, cookies: conn.cookies, query: conn.params},30_000)
    send_resp(put_resp_header(conn,"content-type","text/html;charset=utf-8"), render.param || 200,layout(render))
  end
```

---
## Question time !

* What is **Reaxt** ?
* Why do we use server-side rendering ?
* What does the **EEx** name stands for, and what are its use case ?

---
[Prev Chapter](chap6.html) **Chapter 7** [Next Chapter](chap8.html)


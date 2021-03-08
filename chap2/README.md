# Chap2 - Plugs, Cowboy and Macros

In this chapter we will explore how to do some basic metaprogrammation in Elixir, and use it to develop a basic Web Router.  
We are gonna use the dependency `Cowboy` to implement our HTTP server.  
This chapter is gonna introduce you to the [**Plugs** library](https://hexdocs.pm/plug/readme.html).
  
## Step 0 - The Big Bang, or the rising of Cowboy

### Dependencies

First of all, we are gonna add this libraries to our dependencies.  

``` elixir 
defp deps do
  [
    {:cowboy, "~> 1.1.2"},
    {:plug, "~> 1.3.4"},
    {:poison, "~> 3.1"}
  ]
```

Now we need to run the command `mix deps.get` to download our **mix** dependencies.  

### The Beginning

To start the `Cowboy` application,  you need to add it to the application list 
in our **`mix.exs`** as follows:  

``` elixir
def application do
  [ 
    applications: [:logger, :cowboy],
    mod: {TutoKBRWStack, []}
  ]
end
```

### And there was light

Our cowboy needs to know where to redirect the requests he receives, he's a sharp shooter, but a blind one for now.    
To give him sight, we will **create a new module** handled by a **supervisor**. He will be our [**Router**](https://en.wikipedia.org/wiki/Routing).  
  
To get a worker of our router, we can use the `child_spec/4` function of the 
**`Plug.Adapters.Cowboy`** module. Where the parameters are:  
* The protocol to use for our router (`:http` or `:https`)
* A **Plug Module**, our router _(leave it empty for now, we will come back at it in a second)_
* A list of options for our router (empty `[]` here)
* A list of options for cowboy (we precise here the port with [port: 4001]) 

The complete line looks like 

``` elixir
Plug.Adapters.Cowboy.child_spec(:http, Server.Router, [], [port: 4001])
```

This should allow you to access your web application at the address http://localhost:4001/


## Step 1 - Stone age: the First Plug

Once upon a time there was a module.  
This module was the first of its kind, and was very special: it was possible to call it using the `plug` macro.  
It was a **Plug Module**.    
It's name was `TheFirstPlug`.  
  
---
**Exercice:**  
Create a **Plug Module** called `TheFirstPlug`.  
We will use this module as our Router, and pass it as the second argument of the `Plug.Adapters.Cowboy.child_spec` call.  
  
A **module plug** is an extension of the function plug. It is a module that must export:
  - an `init/1` function which takes a set of options and initializes it.
  - a `call/2` function which takes in parameters a [Plug.Conn](https://hexdocs.pm/plug/Plug.Conn.html) and the options returned by `init/1`  
  
The result returned by `init/1` is passed as second argument to `call/2`. Note that `init/1` may be called during compilation and as such it must not return pids, ports or values that are not specific to the runtime.  
  
_Example of a module plug_:
```elixir
  defmodule JSONHeaderPlug do
    import Plug.Conn

    def init(opts) do
      opts
    end

    def call(conn, _opts) do
      put_resp_content_type(conn, "application/json")
    end
  end
```
_See the file **plug.ex** inside the folder `your_mix_folder/deps/plug/` for more details_
  
When your HTTP server will receive a request, the `call/2` function of your module plug will be called with the `conn` variable corresponding to the current request.  
You can find the requested path using the `request_path` field.  
  
You can send a response using the `send_resp/3` function.  
_Example_: `send_resp(conn, 200, "Hello world")`  
I will let you **look into the documentation** to find out what the differents parameters are.  
  
You router should have the following routes defined:
  - "/" -> Returns code 200, with content "Welcome to the new world of Plugs!"
  - "/me" -> Returns code 200, with content "I am The First, The One, Le Geant Plug Vert, Le Grand Plug, Le Plug Cosmique."
  - All other routes -> Returns code 404, with content "Go away, you are not welcome here."  

Following this, accessing http://localhost:4001/me should display the correct text inside your Web Browser.
  
**Hints:**
  - You can access the sources of the dependencies of your project inside the `deps` folder of your mix application
  - A **Plug** is defined inside the file `plug.ex` of the `plug` dependency
  - In **Cowboy** or **Plug**, when you see the `conn` argument, it refers to [Plug.Conn](https://hexdocs.pm/plug/Plug.Conn.html)

_Usefull links:_
  - https://hexdocs.pm/plug/Plug.Builder.html
  - https://hexdocs.pm/plug/readme.html
  - https://hexdocs.pm/plug/1.1.3/Plug.Adapters.Cowboy.html
  - https://hexdocs.pm/plug/Plug.Conn.html

---

## Step 2 - Bronze Age: Macros, and the Powers of Creation

**For this Chapter, read the Meta-Programming Guide of Elixir [here](https://elixir-lang.org/getting-started/meta/quote-and-unquote.html)**

We have a beautiful HTTP server, with a working router.  
However, it can quickly become difficult to maintain, especially if you want to run custom code before answering to the client request.  
  
To facilitate our life in the long run, we are going to create a [Domain-Specific Language](https://elixir-lang.org/getting-started/meta/domain-specific-languages.html).  
  
At the end of this step, we want to have a router that looks just like this:  
```elixir
defmodule Server.Router do
  use Server.TheCreator

  my_error code: 404, content: "Custom error message"

  my_get "/" do
    {200, "Welcome to the new world of Plugs!"}
  end

  my_get "/me" do
    {200, "You are the Second One."}
  end
end
```
---
**Exercices:**  
Create a module `Server.TheCreator`.  
This module will be used (`use`) by our router, and will contain the implementation details of **two macros**:
   - my_get: Allows the user to define new paths for the web application. It **must** return the HTTP response code as well as the HTTP response content
   - my_error: Allows the user to change the default behaviour of the router in case of an error (the path requested doesn't exist). The default behaviour is `{404, "Go away, you are not welcome here"}`


Our module will use the two private macros `__using__` and `__before_compile__`.    

The first one is gonna import the necessary modules, inform the compiler that we want our macro `__before_compile__` to be called, and initialize some [attributes](https://elixir-lang.org/getting-started/module-attributes.html) like the container of functions to call for each path, or the behaviour in case of error.  
  
The second one will define two functions (`init/1`, `call/2`), that will make the user of `Server.TheCreator` a **Plug Module**.  
  
##### my_get

This macro will create a new function, and store this new function name inside one of our module attributes.  
This will allow our `call/2` function to check if a requested path as been defined, and if so execute the attached function to fetch the return code and the content.  

##### my_error

This macro will change the modules attributes to change the default behaviour in case of a path resolution failure.  
It takes in parameters two arguments, `:code` and `:content`.

__Usefull links:__
  - https://elixir-lang.org/getting-started/meta/domain-specific-languages.html#storing-information-with-attributes

**This part is really important, take your time to understand how macros work. DO NOT look at the correction immediatly, [ask](http://www.catb.org/~esr/faqs/smart-questions.html) questions on the #formation channel first if need be !**

---

## Step 3 - Iron Age: The child prodigy, Plug.Router

By now you should start getting confortable with the **Elixir** syntax and how **Plug** works.  

In this section we will have a look on how to use the module **`Plug.Router`**.  
This module does more or less what you did in the previous section, but better :)  
It provides a useful set of macros, allowing you to handle **REST API** call. 

You can find the documentation of **`Plug`** and **`Cowboy`** here: 
* [**`Plug.Router`**](https://hexdocs.pm/plug/Plug.Router.html)
* [**`Plug.Adapters.Cowboy`**](https://hexdocs.pm/plug/1.1.3/Plug.Adapters.Cowboy.html)


Using **Plug.Router**, our router module should now looks like this: 

``` elixir
defmodule Server.Router do 
  use Plug.Router 

  plug(:match)
  plug(:dispatch)

  get "/", do: send_resp(conn, 200, "Welcome")

  match _, do: send_resp(conn, 404, "Page Not Found")

end
```
_Yes, it's similar to what you created earlier :)_
  
We can see that we need to use the **`Plug.Router`** module, to allow it to 
inject some code in our module.  
We then use the macro `plug`, that precise which function to execute after receiving a message.  
Here, the module will execute the `match/2` and `dispatch/2` functions injected in our module by **`Plug.Router`**.  
After that we can define the behavior of our server with the **`Plug.Router`** macros `get`, `post`, `match`, ...  
  
The `get` macro create a function that handles the `GET` call to the server. 
Here we pattern match the path on `"/"`, which represents the root page of our website.  
  
The `match` macro creates a function that handles any type of call to our server.
As we don't pattern match here, every other call but the `GET` on the root page will be managed by this plug.  
  
The return of the `do` blocks of this macro should be provided to `send_resp/3` which takes the following parameters:  

* The [`conn`](https://hexdocs.pm/plug/Plug.Conn.html) variable that defines the client who needs to receive the information
* The HTTP status code (`200`, `404`, ...)
* The page to return to the client (This can contain an HTML page, a JSON for API call, ...)

---
**Exercice:**

Create a **REST API** allowing the user to interact with the database you defined in the previous chapter.  
We should be able to delete, search, update, etc. using routes.  
We should be able to call a route like this: `http://localhost:4001/search/?id=42&value="oui"`  
  
_See the documentation for more details on how to fetch the query parameters._  

---
## Question time !

* What are the `Plug`s "Connection adapters for different web servers in Erlang VM"
* What utilities does they have ? they are use t oconnect multiple vm's
* What should `defmacro` return ? It should return a quoted expression
* Why use the `Poison` dependency ? To switch for json to sting and string to json
* What does the `use` keyword do ? What are the differences with `require` ?

It requires the given module and then calls the __using__/1 callback on it 

Require makes the macros from the require’d module available to the current lexical scope.
"Use" call "Require" and call the __using__/1 callback of the module

---

[Prev Chapter](chap1.html) **Chapter 2** [Next Chapter](chap3.html)

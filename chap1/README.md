# Chapter 1 - GenServer, ETS Table and Supervisor 

In this chapter we will discover the wonderful world of **`GenServer`**, 
**`Supervisor`** and **`ETS Table`**. The objective of this chapter is to 
create an **`ETS Table`** managed by a **`GenServer`** which is supervised 
by a **`Supervisor`**

## Step 0 - My Homemade GenServer

In this step we are gonna re-implement an [**Elixir GenServer**](https://hexdocs.pm/elixir/GenServer.html) using [**raw Process**](https://hexdocs.pm/elixir/Process.html).  
  
I invite you to read a bunch of this documentation, so that you know where we are going:
* [GenServer](https://hexdocs.pm/elixir/GenServer.html)
* [Process](https://hexdocs.pm/elixir/Process.html)
* [Elixir Guide on Processes](https://elixir-lang.org/getting-started/processes.html)
  
I also encourage you to checkout a mini course, wrote by our CTO, Arnaud Wetzel. It will give you a better understanding of what happens backstage when you use a GenServer.  
The course is available right here on [GitHub](https://github.com/awetzel/imt_actor_course_2017).

---
**Exercice:**  
Create a module named `MyGenericServer`.  
This module should contains 4 functions:
  - `loop/2({callback_module, server_state})`
    - The main loop of our process.
    - The `callback_module` contains callback functions that will be called by our server
    - It's gonna use the `Kernel.send/2` and `Kernel.receive/1` functions to communicate
    - It's gonna call itself recursively
    - Inspire yourself from the [Elixir Guide](https://elixir-lang.org/getting-started/processes.html)
  - `cast/2(process_pid, request)`
    - This is just a wrapper to communicate with your Process using `Kernel.send/2`
    - It should have the same return format as the `cast` function of a `GenServer`
  - `call/2(process_pid, request)`
    - This is also a wrapper to communicate with your Process using `send`
    - This time, it should return the result calculated by your process depending on the `request`
    - It should have the same return format as the `call` function of a `GenServer`
  - `start_link(callack_module, server_initial_state)`
    - Utility function that will instantiate your server using `spawn_link/1`
    - It should return `{:ok, your_process_pid}`
  
In your `loop/2` function, you will call the corresponding `handle_cast/2(request, state)` and `handle_call/2(request, state)` function of your `callback_module` when needed.  
The **cast** handler will return the new inner state of your server.  
The **call** handler will return the response of the call, and the new inner state of your server.  
  
Giving all this, I should be able to use your `MyGenericServer` like this:
```elixir
defmodule AccountServer do
  def handle_cast({:credit, c}, amount), do: amount + c
  def handle_cast({:debit, c}, amount), do: amount - c
  def handle_call(:get, amount) do
    #Return the response of the call, and the new inner state of the server
    {amount, amount}
  end

  def start_link(initial_amount) do
    MyGenericServer.start_link(AccountServer,initial_amount)
  end
end

{:ok, my_account} = AccountServer.start_link(4)
MyGenericServer.cast(my_account, {:credit, 5})
MyGenericServer.cast(my_account, {:credit, 2})
MyGenericServer.cast(my_account, {:debit, 3})
amount = MyGenericServer.call(my_account, :get)
IO.puts "current credit hold is #{amount}"
```

---
## Step 1 - ETS Table

The **`ETS`** documentation is available 
[here](http://erlang.org/doc/man/ets.html). You can  also have a look to 
the **Elixir** official tutorial 
[here](https://elixir-lang.org/getting-started/mix-otp/ets.html)

As you can see in the documentation, `:ets` is an **Erlang** module. 
To access **Erlang** modules in **Elixir** you need to use their Atom 
name (here `:ets`). 

Let's create our first `:ets` table. 

``` elixir
my_table = :ets.new(:table, [])
```

The variable `my_table` now contains an id pointing to our table named `:table`. 
To access your table you will need to provide this id to the methods of the 
`:ets` module, as follows. 

``` elixir 
:ets.insert_new(my_table, {key, value})
:ets.lookup(my_table, key)
```

As you can see, you need to save your table id inside a variable if you want to access your table. This might become unconfortable if you want to 
access it from isolated part of your code.  
**Erlang** is smart and allows you to solve this problem pretty easily. The `:named_table` option will allow you to call it using you table's atom: 

``` elixir
:ets.new(:table, [:named_table])
:ets.insert_new(:table, {key, value})
:ets.lookup(:table, key)
```

*(Be sure here to delete your previous :table before recreating one with 
the same name)*

**Hint:** This option is also pretty common among modules like **GenServer** and **Supervisor**.  
  
**Exercise:**  
Here, we suggest you to play with the `:ets` module and have a
quick look to the tutorial provided by **Elixir**.
  
## Step 2 - GenServer

The **GenServer** documentation is available [here](https://hexdocs.pm/elixir/GenServer.html).  
I recommend you to have a look to the **Elixir** official tutorial [here](https://elixir-lang.org/getting-started/mix-otp/genserver.html)  

**`GenServer`** is an elixir module that helps you manage a multi-threaded environment. A **`GenServer`** is a `Process` that owns an internal value.
To implement a **`GenServer`** module you only need 
to `use` the **`GenServer`** module and implement the function `init/1`. 
To start your server, use the function `GenServer.start_link/3`

First, lets have a look to thoose functions.

``` elixir
defmodule Server.Database do 
use GenServer 

def start_link(initial_value) do
  GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
end

def init(_) do
  {:ok, :ok}
end 
``` 

Here the function `start_link/1` allows our module to start our process. 

As you can read in the [documentation](https://hexdocs.pm/elixir/GenServer.html#start_link/3) of the `start_link/3` function of the 
module **`GenServer`**,
the first argument is the module's name where **`GenServer`** will look 
for the `init` function, the second argument is the initial value of the 
internaly stored variable, and the third argument are the options for the **GenServer**.

The `init/1` function of our module is the function called on start up 
by the **`GenServer`** module. This function is supposed to return a tuple, 
matching on `{:ok, _}`, where the second element of the tuple is the internal
stored value of the **`GenServer`** after the initialization.

The **`GenServer`** communication API is composed of 2 main functions and some
derivated functions. The main ones are `call/2` and `cast/2` which allows the user to make respectively synchronous and asynchronous calls to the **GenServer Process**. 

To handle the call to its API, our **`GenServer`** module have to implement the
**callbacks** `handle_call/3` and `handle_cast/3`. You can use the **module attribute `@impl true`** to inform the compiler that your function is a callback. Learn more about **module attributes** and **callbacks** [here](https://hexdocs.pm/elixir/master/Module.html)

Let's have a look to the `call/2` and `cast/2` signature. And then then 
have a look to the parameters given to the `handle_call/3` and `handle_cast/3` 
functions. 

``` elixir
value = GenServer.call(__MODULE__, object)
:ok = GenServer.cast(__MODULE__, object)

@impl true
def handle_call(object, _from, intern_state) do 
  {:reply, object, intern_state}
end

@impl true
def handle_cast(object, intern_state) do 
  {:noreply, intern_state}
end
```

We can see here that you can call your GenServer by furnishing to the API the `<PID>` or the `:name` of your GenServer as first argument, and the 
request to be given as second argument. These calls will return 
the 2nd element of the tuple return by `handle_call/3` and the `:ok` atom for 
the cast. 

The handlers first element is the request passed by the `call/2` and 
`cast/2` functions. The second argument of the `handle_call` functions is 
the `<PID>` of the calling process. The last argument of these functions is 
the internal state of the server.  
These handlers **have** to return a tuple, in 
which you can find at the first place the type of answer returned by the 
**`Genserver`**, at the second place the value returned by the `call/2` function,
and at the last place the new internal value of your GenServer.
  
## Step 3 - Supervisor 

The **Supervisor** documentation is available 
[here](https://hexdocs.pm/elixir/1.3.4/Supervisor.html). 

There is two ways to use the **Supervisor** module:

1. The first way is to 
create a custom **Supervisor** module using(`use`) **`Supervisor`**.
The defined module must implement the functions `start_link/0` and 
`init/1`. 
    * The function `start_link/0` allows you to launch your **Supervisor** 
    ``` elixir
    def start_link do
      {:ok, _} = Supervisor.start_link(__MODULE__, [], name: __MODULE__)
    end
    ```

    * The function `init/1` is called by the function `Supervisor.start_link` 
called previously. This function should call the **`Supervisor`**'s macro
`supervise` as follows:
    ``` elixir
    def init(_) do  
      children = [MySupervisedModule]
      supervise(
          Enum.map(children, &worker(&1, [])),
          strategy: :one_for_one
          )   
      end
      ```

    With `children` the list of modules that implement a `GenServer`, a `Task`, ... 
And `worker/2` a function that take as first argument your module and as second 
argument your module's `start_link/1` argument.

1. You can also directly start a supervisor on your **`GenServer`** with the 
following code: 

    ``` elixir
    defmodule TutoKBRWStack do
      def start(_type, _args) do
        import Supervisor.Spec
        children = [worker(Server.Database, [0])]
        opts = [strategy: :one_for_one]
        Supervisor.start_link(children, opts)
      end 
    end
    ```

    As for the previous version, in this case, you need to create a children
    list containing the worker of you **`GenServer`**, and a list containing
    the options of your supervisor. Then you need to start your supervisor
    with the `start_link/2` function as for a server. 

## Step 4 - My Key-Value database
---
**Exercise:** create a **`GenServer`** module in your project to manage an **ETS Table** supervised by a **`Supervisor`** The type of entity stored in ETS table doesn't matter now, the idea here is to re-implement a key/value database.  

Your database **must** respect the [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) principles.  

Here is an example of what could be your file hierarchy:
* `lib/sever/database.ex` is the module containing our **`GenServer`**
* `lib/server/serv_supervisor.ex` is the supervisor (Following the first method)
* `lib/tuto_kbrw_stack.ex` is our application started by mix.
---

_Why not create some unit tests to verify that our database is fully functional ? :)_

## Step 5 - Let's fill it !

Now that our database can store anything we want, let's add some usable information inside it !  
  * **The data**  

You will find attached to this formation a ZIP file `orders_dump.zip` containing a bunch of JSON files.  
It should look something like this:  
``` 
  orders_dump/
  |-- orders_chunk0.json
  |-- orders_chunk1.json
  |-- orders_chunk10.json
  |-- etc.
```
  
Each one of this files contains a list of orders, I will let you look into it and familiarize yourself with the different fields representing an order.  

  * **The loader**

We will now have to load this orders inside our key-value database.  
We will chose the field **id** of each order as the key, and store a **Map (%{})** as value.  
This Map will be the representation in Elixir of the order's JSON.  

For that we will use an external dependency called [Poison](https://hexdocs.pm/poison/api-reference.html).  

---

**Exercice**:  
 Create a function `load_to_database` inside a **Module** `JsonLoader`.  
 The function **must** respect this prototype `load_to_database/2(database, json_file)`  
 The function will parse the `json_file`, and write inside the `database` the key value pair defined as follow:  
 `{order_id, %{order_data}}`.  
  **Poison** will help you convert JSON to an Elixir Map representation.  
   
 I should be able to call it like this:  
 `JsonLoader.load_to_database my_kv_db, "/path/to/my/json.json"`  

---
 _Usefull links:_
 - https://hex.pm/docs/usage
 - https://hexdocs.pm/poison/api-reference.html
 - https://hexdocs.pm/elixir/File.html
 - https://www.json.org/index.html

_If you have any questions, do not hesitate to [ask](http://www.catb.org/~esr/faqs/smart-questions.html) on the #formation channel_

## Step 6 - The search engine

Perfect ! Now we're getting somewhere.  
We have a functional KV Database, some cool orders in it, and we can sear... wait... no... we can't search inside our DB ! :(  
We're gonna fix that ! After all, aren't we  **Elixir ninjas** ?  

---
**Exercice**:  
 Create a function `search` inside your `Database` module.  
 The function **must** respect this prototype `search/2(database, criteria)`  
 Where `criteria` is a **List []** containing couples of Key / Values.  
 The function must check on each orders if the corresponding keys have the same values, using a _OR_ operation (see example).  If yes, the order is appended to a result list which will be return by the function.  
   
 **_Example:_**
  ``` elixir
    orders = [
      %{"id" => "toto", "key" => 42},
      %{"id" => "test", "key" => "42"},
      %{"id" => "tata", "key" => "Apero?},
      %{"id" => "kbrw", "key" => "Oh yeah"},
    ]
    ## ...
    ## Load the orders inside the database "kv_db"
    ## ...

    {:ok, orders} = Database.search(kv_db, [{"key", "42"}])
    orders = [%{"id" => "test", "key" => "42"}]

    {:ok, orders} = Database.search(kv_db, [{"key", "42"}, {"key", 42}])
    orders = [%{"id" => "test", "key" => "42"}, %{"id" => "toto", "key" => 42}]

    {:ok, orders} = Database.search(kv_db, [{"id", "52"}, {"id", "ThisIsATest"}])
    orders = []
  ```
---
## Question time !

* Why use an ETS table ?
* What are the advantages of wrapping an ETS table inside a GenServer ?
* What is a `Behaviour` in Elixir ?

**Go further**
* What are the differences between a `Protocol` and a `Behaviour` ?
* In which cases would you want to use a `Protocol` ? a `Behaviour` ?

---
[Prev Chapter](chap0.html) **Chapter 1** [Next Chapter](chap2.html)

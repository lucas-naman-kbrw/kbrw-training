# Chapter 8 - Rulex, ExFSM and Have fun

In this chapter we will enable the payments of our orders. To achieve that we will create a tiny [Finite-state machine (FSM)](https://en.wikipedia.org/wiki/Finite-state_machine).  
  
By doing so, you will discover two new home-made libraries: [ExFSM](http://github.com/kbrw/exfsm) and [Rulex](http://github.com/kbrw/rulex).  
  
## Step 0 - Prerequisite

### The FSM 

The FSM looks like the following schema. It's a very light FSM that allows you to change the status of your command from unpaid to paid. 

![FSM](./img/FSM.png)

### Initialization of Riak

Before anything, we need to assure that all our values in the database have their status set to our FSM default state. We want that all the commands on Riak respect the following property:

``` js
command.status.state == 'init';
```

``` elixir 
def initialize_commands(bucket) do 
  Riak.get_keys(bucket)
    |> Enum.map(
      fn key -> 
        # update the json here 
      end)
  end 
```
### The mix dependencies 

We will need the following dependencies in our **`mix.exs`** 

``` elixir 
defp deps do 
  [
    ..., 
    {:rulex, git: "https://github.com/kbrw/rulex.git"},
    {:exfsm, git: "https://github.com/kbrw/exfsm.git"}
  ]
```

### The Macros

To use correctly **`ExFSM`** and **`Rulex`**, we will need to understand correctly the macros and how 
it is implemented in **Elixir**. 

A Macro in **Elixir** is, like in C/C++, a sort of function executed at the compilation time. They are 
used to generate code or modify it. 

When elixir is compiled, the code is transformed into an AST that you can obtain by using the `quote` 
keyword.

``` elixir 
iex(6)> quote do 
...(6)> 1 + 2 + 3
...(6)> end 
{:+, [context: Elixir, import: Kernel],
 [{:+, [context: Elixir, import: Kernel], [1, 2]}, 3]}
```

As you can observe, the AST is represented by a tuple of 3 elements. (*It can also be one elements if 
this element as the same representation compiled and not (`1`, `"toto"`, ...)*). With : 
* Name of the block
* Contexte of the block in a list 
* Code block in a list of instruction

When you execute a macro, it takes as input the AST of the code you passed and expects an AST as output.  
Let's create a macro that create a function from a do block and apply a prefix on the function name.  
It will be used as follows 

``` elixir 
defmodified toto(a,b,c) do 
  a+b+c
end
```

And it will create the function `macroed_toto/3`. 

First let's observe the generated AST from `defmodified` 

``` elixir 
iex(1)> quote do
...(1)> defmodified toto(a,b,c) do
...(1)> a+b+c
...(1)> end
...(1)> end
{:defmodified, [],
 [{:toto, [], [{:a, [], Elixir}, {:b, [], Elixir}, {:c, [], Elixir}]},
  [do: {:+, [context: Elixir, import: Kernel],
    [{:+, [context: Elixir, import: Kernel],
      [{:a, [], Elixir}, {:b, [], Elixir}]}, {:c, [], Elixir}]}]]}

```

If we consider here that `defmodified` is our macro, we will see that our macro will take as parameters

``` elixir 
{name, environment, param}, blocks
```
with here: 
* `name` is `toto`
* `environment` the environment module of the macro call
* `param` the list of parameters of the function: `[a,b,c]`
* `blocks` a list containing the instruction of the function 

So, to create the function we will create a **Tuple** of the name `:def` containing the information of
the function as the ouput AST should be:

``` elixir 
iex(24)> quote do 
...(24)> def macroed_toto(a,b) do 
...(24)> a+b
...(24)> end 
...(24)> end 
{:def, [context: Elixir, import: Kernel],
 [{:macroed_toto, [context: Elixir], [{:a, [], Elixir}, {:b, [], Elixir}]},
  [do: {:+, [context: Elixir, import: Kernel],
    [{:a, [], Elixir}, {:b, [], Elixir}]}]]}
```

We need to create the external tuple with the name set to `:def` and the environment of the macro definition

``` elixir 
defmodule ModifiedMacro do
  defp concatenate_atom(a, b) do
    Atom.to_string(a)<>Atom.to_string(b) |> String.to_atom
  end

  defmacro defmodified({name, env, param}, blocks) do
    {:def, env, [{concatenate_atom(:macroed_, name), env, param}, blocks]}
  end
end

defmodule User do 
  require ModifiedMacro
  import ModifiedMacro 
  
  defmodified my_function(a,b) do 
    a+b
  end 
end
```

After compilation, the module **`User`** implements the function `macroed_my_function/2`

``` elixir 
iex(1)> User.
macroed_my_function/2

iex(1)> User.macroed_my_function(1,2)
3
```

## Step 1 - ExFSM

As we want to understand how the modules works, we will have to go in the source directly. 

Dive in the source of [**ExFSM**](https://github.com/kbrw/exfsm) at `deps/exfsm`. 
In the file `exfsm.ex` you will find the definition of the macro `deftrans`. 

This macro add to your FSM(`@fsm`) a transition from the `initial_state` and the `final_state`. 

``` elixir 
deftrans initial_state({:transition_event, []}, object) do 
  {:next_state, :final_state, order}
```

After defining all the transition of our FSM, we will need to implement the protocol of our FSM.  
**If you are not familiar with the principle of the protocols have a look [here](https://elixir-lang.org/getting-started/protocols.html).**  
  
In this implementation, you need to provide the following functions: 
* `state_name` that takes as parameter your order and return as an **Atom** the state of your order.
* `set_state_name` that takes as parameter your order and the name of your order, and return your order 
with a state updated to the new state. 
* `handlers` is the list of all the FSM modules. Here we have only our `MyFSM` module. 

A simple working 2 states FSM is written as follows: 

``` elixir 
defimpl ExFSM.Machine.State, for: Map do
  def state_name(order), do: String.to_atom(order["status"]["state"])
  def set_state_name(order, name), do: Kernel.get_and_update_in(order["status"]["state"], fn state -> {state, Atom.to_string(name)} end)
  def handlers(order) do
    [MyFSM]
  end
end

defmodule MyFSM do                                                                                      
  use ExFSM

  deftrans init({:process_payment, []}, order) do 
    {:next_state, :not_verified, order}
  end 

  deftrans not_verified({:verfication, []}, order) do 
    {:next_state, :finished, order}
  end
end
```

Now if we want to make a transition on an order we can call our FSM as: 

``` elixir 
{:next_state, updated_order} = ExFSM.Machine.event(order, {:process_payment, []})
```
---

### Explaination of the ExFSM Module

Now that we understand how to use the **`ExFSM`** module, we will dive into the source code to 
understand exactly what is expected by the macro. 

``` elixir
  defmacro deftrans({state, _meta, [{trans, _param} | _rest]} = signature, body_block) do                      
```
This macro add to the [module attribute](https://elixir-lang.org/getting-started/module-attributes.html) `@fsm` (which is a map)
the transition. This transition key is the tuple `{current_state, action}` (for instance 
`{:init, :process_payment}`) and the body of the transition is the tuple `{module, do_block}`. 

Now let's have a look on how the module works when we call the `ExFSM.Machine.event/2`. 

``` elixir 
def event(state, {action, params}) do
```
First, the event search the handler to execute for this couple `{state, action}` by executing the 
function `find_handler/1` which will call `find_handler/2` with parameters:
* The tuple `{state, action}`
* The list of all modules returned by the implementation of `handlers/1`

This will return the transition `{state, action}` in the map created by the contenation of all the FSM 
in the second parameter.  
This concatenation is done by the function `fsm/1`. This concatenation is done by overwriting. 
It means that the last FSM with the transition {:state, :transition} will be written in the new FSM.
That is why, we need to put the default FSM first in the list of `handlers/1`.  
Then in the `event/2` function, if the given transition exists in the FSM, the associated do block is 
executed.

---

## Step 2 - Rulex

Now that we have an FSM, we will work with multiple FSM! Let's have a look in [**`Rulex`**](https://github.com/kbrw/rulex).  

The aim now that you understand how **ExFSM** works is to implement different payment solutions in our FSM. **`Rulex`** will allow us to 
pattern match the FSM that could handle our call.  
Here we will have a FSM for: Paypal, Stripe, and the default payment method: Delivery.  
In the **`Rulex`** module, we will use the macro `defrule`.  
This macro allows you to accumulate in an object through an accumulator under a certain condition. This condition can be updated easily 
by changing the input of the function `apply_rules/2`.  
The same as for **`ExFSM`** you can dive into the code of the **`Rulex`** module.  

--- 

### Explaination of the Rulex module 

The macro `defrule` use the function `rule_fun/5`. This function take as parameters: 
* `name` which is the name of the macro 
* `param_quote` which is a quoted form of the parameters given to our macro (first parameters of the 
macro).
* `acc_quote` the quoted form of the accumulator.
* `body` is quoted form of the body of our macro (`do` block)
* `guard_quote` the quoted form of the guards. (`when is_integer(toto)` is called a guard in elixir)

This function define the function `apply_rules/4` which will be called by the function `apply_rules/2` defined in the `__before_compile__` section injected in our module by the `__using__` macro. 

---

Now let's define a rule as example. 

``` elixir 
defrule paypal_fsm(%{payment_methop: :paypal} = order, acc), do: {:ok, [MyFSM.Paypal | acc]}
```

* The first argument is the pattern match of the parameter given as first argument to `apply_rules/2`
* The second argument is the current accumulator (as seen in the explaination paragraph)
* The `do` blocks is the accumulation of the element in the accumulator (here our FSM)

## Step 3 - Handle the transitions: GenServer 

Now we will see how to use our new modulable FSM. 

``` elixir
defrule paypal_fsm(%{"payment_method" => "paypal"} = order, acc), do: {:ok, [MyFSM.Paypal | acc]}
```
_With this rule you need to set the `payment_method` attribute of your order to change the FSM used on the call_

---
**Exercise:**  

  * Setup an FSM and implement a GenServer module that will handle the transitions of your `order FSM` in a **transactionnal manner** (processes can only treat one message at a time, the rest is kept ordered in their message queue).
    * The GenServer will be started on demand
    * When a transaction needs to be made.
      * It will be started with the order as its initial state (the id must be provided)
      * Process the transaction in an `handle_call`
      * Update the state of the order in Riak
      * Return the updated order or an error (`:action_unavailable`)
      * Shutdown once all that is done.  
  
  * Once you're done with that, add a new Web API to your project that triggers a transitions on an order FSM, and return the new order or an error.
  * Link it to your `pay` button on your `orders` page.  
  
_Take some time to play with it, display the status of your order in your table, and make it change once the transaction is done.  
Display an error on your front if the action triggered is not available._

---
## Question time !

* What is the signifiaction of **FSM** ?
* Can you explain what does `quote` ?
* Is Rulex result based on the first true value, all the values, or the last matched value ?
* Can you show me in cmd line an exemple of FSM transition?

---
[Prev Chapter](chap7.html) **Chapter 8** [Next Chapter](chap9.html)
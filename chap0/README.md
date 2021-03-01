# Introduction

You're about to start your KBRW training. This course will provide you with some guiding through the setup and building a minimalist web project from scratch, KBRW style! You must understand couple of things though before you begin your journey:

- **You must code !** Reading some docs and tutorials is always a good start, but it's only by getting your hands dirty and trying to make something of what you just learned that you'll really learn something.

- **You must struggle !** A big part of this training is about you struggling with some setup or some code. We want you to get the full experience of working on project at KBRW. Issues you'll deal with now will make you stronger and faster when you'll meet them again on your futur project.

- **You must ask for help** When you feel you've struggled for too long, don't hesitate to ask arround, to your futur colleagues and especially to your KBRW tutor. We'll always find time to help you move pass this obstacle.

Finally, as much effort as we put in this training, it's most likely outdated... Some parts or lines of code may not work, so you'll have to dig and find for yourself a path to resolution. But in case you're really struggling with something, checkout our #formation channel on Slack, as someone has probably already had the same issue. If not, ask arround, we'll help you get there.

At the end of each chapter, you'll be asked to implement a new part of your project using what you just learnt. It is important that you take time to do it by yourself before checking out the correction.

To follow your evolution and make sure you went through the entire training like a champion we ask you to regularly commit and push your work to a remote Git repository. Your tutor will regularly assess your progression and give you feedback on your work.

On your first week at KBRW you'll be asked to run and present your project from start to end to someone and detail the work and difficulties you went through to get there. This is not an evaluation, we just want to make sure you're fully armed before you start kicking some ass on one of our projects ;-)

Remember, this training is not easy. We don't expect you to finish it in a week. We generally give you a full month to complete it, so please take the time you need to do it thoroughly, so you fully understand our tools and ways of building projects.

# Your work environnement

For you to have the best work environment for your training we recommand you run:

- The lastest **Ubuntu Long Term Support version (v 18.04 right now)**, or equivalent
- Or the **second to last macOS version (v 10.13 right now)** if you're a **Mac** user

We recommend you **never** use the latest, bleeding edge version of anything, or you'll risk wasting time debugging some unseen, undocumented issues. And that's just not the purpose of this training as we prefer you to focus on our stack.

# Prerequisite

First thing first, to follow this training you will need to have some good basis in Elixir. So before you follow this course you **must** have done the entire [Elixir Getting Started](https://elixir-lang.org/getting-started/introduction.html) followed by the [Introduction to Mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html).

Once you feel like your a true Elixir Ninja, you can read what's bellow and start your KBRW training.

**Good luck ! ;-)**

# Chapter 0 - Elixir, ASDF and Mix

In this chapter we will get more familiar with **Elixir**, **asdf** and **mix**.

Before coding anything, remember to create your git repository so we can follow your progression.

## Step 0

In this step we will introduce you to `asdf`.

`asdf` is a software version manager, available on [GitHub](https://github.com/asdf-vm/asdf).

In this tutorial, we will use **Elixir 1.3.4**, an old version of Elixir, but asdf provides you an easy way to install it.

First we need to clone and install `asdf` in our home directory as described
on the `asdf` README.

Then we need to install the **Erlang** and the **Elixir** plugins. For that,
you simply have to run the following commands.

    asdf plugin-add erlang
    asdf plugin-add elixir
    asdf install erlang 19.0
    asdf install elixir 1.3.4
    asdf global erlang 19.0
    asdf global elixir 1.3.4

_`erlang` needs the following dependencies to work `libssl-dev`, `automake`, `autoconf` and `libncurses5-dev`._

The two first commands add **erlang** and **elixir** to the dependencies of
`asdf`. The two seconds install, in a `asdf` folder, **erlang** and **elixir** in
their respective versions **19.0** and **1.3.4**.

The two last commands set the **erlang** and **elixir** installs available in a
global environment. You can also set the `asdf` option to `local` to restrict
the environment of your installation to the directory you are currently in and
all it's child folders.

## Step 1

In this step we will discover how to create a `mix` project, compile it and
run a `iex` instance in the `mix` project environment

To create a `mix` project run the following command:

    mix new <nameofyourproject> --sup

This command will generate a mix project containing the different folders:
**`config`**, **`lib`** and **`test`** with the file `mix.exs`

The \***\*mix.exs\*\*** is the project description file. It contains an **elixir**
module that `use` the library **`Mix.Project`** and implement the `mix` required
functions to enable `mix` to compile our project.

- `project` function returns the state of the project, with the version
  of **elixir** supposed to be used, the version of the project, ... This also
  declares the dependencies of the project in the `:deps` element by calling the
  function `deps` I will describe later.
- `application` function returns the list of applications and modules to start
  at the start up of the project. Here we have the `:logger` application, that
  enable a minimum log during the execution of the project. You can also specify
  the execution of a module on start up with the tag `:mod` in the list. Here,
  we start our **`TutoKBRWStack`** module. To start a module that way, the module
  must implement the function

```elixir
def start(type, args)
```

- `deps` function returns the list of dependencies needed by the project. This
  will download the modules required in the folder **`deps`**. We will talk
  more deeply about this function and its implication later in this tutorials.

I will now list the command that you will need to compile, execute and reload
a mix project.

\***\*Compilation\*\***: To compile a mix project you need to run the command:

    mix compile

\***\*Launch\*\***: To launch the project, you can run the following command. Be
careful, this command include the compilation of the project in it. This must
be run in the root folder of your poject

    iex -S mix

\***\*Reload\*\***: You can reload the project while in an `iex` instance. The first
way is to compile the project in a terminal and then in an `iex` instance already
running type `r` <ModuleToReload>

    mix compile
    iex> r <ModuleToReload>

Be careful here, reloading a sub module will only load this sub and all its
submodules, while reloading the main module will load everything.

In a `iex` instance, running following command is equivalent to run the above
command on the main module.

    iex> recompile

If you want to learn more about `mix`, the documentation of the **`Mix`**
module is available on [HexDoc](https://hexdocs.pm/mix/Mix.html). I also
recommend you to read
[this](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)
quick introduction to `mix` on the **elixir** offcial website.

## Question time !

- Do you know the differences between a bitstring, a binary and a charlist ? How do you write them in Elixir ? In Erlang ?
  A bitstring is a contiguous sequence of bits in memory.
  A binary is a bitstring where the number of bits is divisible by 8.
  A string is a UTF-8 encoded binary
  We can write them using the binary / bitstring constructor "<<>>" ex: <<3:: 4>>. Same in Erlang
- What is the main difference between a Stream and an Enum ?
  Streams are lazy, composable enumerables.
  Instead of generating intermediate lists, streams build a series of computations that are invoked only when we pass the underlying stream to the Enum module. Streams are useful when working with large, possibly infinite, collections.
- Sort this data structures from the cheapest to the most expensive one in terms of number of operations and CPU time:
  - List 3
  - Bitstring 1
  - Charlist 2

---

[Next Chapter](chap1.html)

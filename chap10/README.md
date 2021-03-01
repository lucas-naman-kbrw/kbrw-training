# Chapter 10 - SA_DEPS, and Welcome to KBRW

# Introduction

Congratulation, you've made it to the end! 

You will have to do this last chapter on your first day at KBRW, as it requires access to some private resources.

In this chapter we'll give you final explanations on tools we use to develop our projects and how to set them up. 

# Step 0 - Set up the VPN

Some resources of the company can only be accessed via our **VPN**.  
You will find attached to this chapter a `VPN/` sub-directory, with inside it a `shell` script.  
  
If you are on debian, it should help you: `sudo ./confvpn.sh <id> <password>`.  
  
We also wrote a documentation about how to use the VPN. You can access it [here](./VPN.html).  
  

## Step 1 - Get dependencies and endpoints example

First we will need to add the `:sa_deps` dependency: 
```
{:sa_deps, git: "ssh://git.kbrwadventure.com/~git/sa_deps"}
```
And we need to add `:sa_deps` on the start up application in our mix file.

Then let's clone the `endpoint` repository which provides some bypass. 
```
git clone ssh://<username>@git.kbrwadventure.com/~git/endpoint
```
In the folder `endpoints/` you will find all the json that describe the endpoints of your project. 
To allows the application to access it you can simply run the following python command once you are in 
the directory `endpoints/`: 
```
python -m  SimpleHTTPServer 8000
```
This will give access to this directory on the port 8000 of your localhost. 

As these endpoints are always required by the project, I recommend you to alias the following command: 
```
alias start_endpoint='cd $endpoint && python -m  SimpleHTTPServer 8000'
```
where `$endpoint` is the location of all the json files.

Let's create an endpoint for our local Riak server in the endpoints. 

```
[tutoex.json]
{
  "local_riak":    {"endpoint": "http://localhost:8098"}
}
```

## Step 2 - Dive into the SA\_DEPS source.

In the different projects, `sa_deps` allows you to access to the endpoint given depending on your 
environement from: `localhost:8000`, `http://qa-endpoint.priv.qa.kbrwadventure.com/`, `http://pp-endpoint.priv.pp.kbrwadventure.com/`. 

To access to the correct endpoints, `sa_deps` needs to have as `Application` configuration the address 
of the endpoints and the name of the project. So we need to add the sa\_deps configuration to our 
project config in `config/config.exs`: 
```
sa_deps: [
    endpoint: "http://localhost:8000/tutoex.json",
    project: :bib_mdo_ui,
  ]
```

### Now let's dive into the code of `sa_deps` to understand how to use our endpoints:

Let's read the code we need to install our endpoint `lib/sa_deps/directory.ex `. 
(You are encouraged to have a look to all the other files but we won't present them all here).

In this file we will find all the project endpoint description. But it's not a good practice to commit
on the `sa_deps` repository. So we will write it in our project. 

```
defmodule Endpoints do
  require :sa_deps
  def riak_base_url do 
    :sa_deps.url(["local_riak", "endpoint"])
  end
end
```

Now you have your url in the module `Endpoints`

---
[Prev Chapter](chap9.html) **Chapter 10**

# Chapter 6 - RIAK, the NoSQL Database

In this chapter, we will see how to install **`Riak`**, a distributed NoSQL key-value data store, in a Docker.  
We will query it via an **Elixir** application through the **Riak's HTTP API**.  
  
The aim is to create a *bucket* in **Riak**, in which we will store some commands and index them in order to query them later on our front.

## Step 0 - Install Riak in a docker container

To be able to install **Riak** in a docker container, you need to install the 
`docker` and `docker-compose` software. 

    sudo apt-get install docker
    sudo apt-get install docker.io
    sudo apt-get install docker-compose

Then you can start your `docker` container with **Riak** inside by simply running 
the following commands in the `riak` folder containing the file `docker-compose.yml`

    sudo docker volume create --name=schemas
    sudo docker-compose up -d
    sudo docker-compose scale member=5
  
_On Mac you can install https://hub.docker.com/editions/community/docker-ce-desktop-mac._  
  
If it succeeded you should be able to connect to the following address: 
[localhost:8098/buckets?buckets=true](http://localhost:8098/buckets?buckets=true).  
  
It is supposed to answer:  
  
```js
{"buckets":[]}
```
  
*If you have trouble connecting to the server, consider rebooting here.*  
  
Let's have a look to the commands: 
* `volume create` creates a link between a container and the real disk in order to 
allow the container to access to a directory outside of its own root. This is done by the tag `external: true` in the `docker-compose.yml` file.
* `up -d` start the docker described by the file. You need to execute this 
command each time you have a reboot your computer, in order to restart the 
docker container. 
* `scale member=<number>` this command set the number of container `member` to `<number>`. So now you should have 1 coordinator node and 5 member nodes. You 
can check it by running the command `sudo docker ps`

**Some tips**  
  * You may want to downscale your number of `member` to `2`
  * As always, go read some docs about `Docker`, `Docker Compose` and `Riak`

## Step 1 - Set up the search engine 

To be able to search in your data, you need to activate the search engine in every node of riak: https://docs.riak.com/riak/kv/2.2.3/configuring/search/index.html#enabling-riak-search.  
  
You can either go inside each container and modify its inner configuration, or use the `volume` option inside your `.yaml` file to add a `user.conf` file automatically at the creation of the container.  
  
_I will not tell you how to do it. You have to go and learn by yourself for that :)_  
  
**Depending on your choice, you will have to restart or re-build your containers.**  
  
At this point, your nodes should be able to talk with [**Solr**](http://lucene.apache.org/solr/), which is the engine that performs the research operations for **Riak**.  

## Step 2 - Discovering Riak HTTP API

Now your **Riak** database should be set up and we can start working with it.

The **Riak HTTP API** is available [here](http://docs.basho.com/riak/kv/2.2.3/developing/api/http/). 

What is **Riak**? **Riak** is a *NoSQL* database.  
**Riak** architecture is based on writing data in `bucket`, with each data associated to a key exaclty like for the **ETS Table**. 
![Cannot find image riak\_data\_architecture.jpg](img/riak_data_architecture.jpg)
*You can see above the architecture of Riak data*
  
Here we will use the `:httpc` **erlang** module to query the **Riak HTTP API**.
The `:httpc` module documentation is available [here](http://erlang.org/doc/man/httpc.html). 

To use `:httpc` we need to launch the `:inets` application in our **mix.exs**.

``` elixir
def application do
  [ 
    applications: [:logger, :cowboy, :inets],
    mod: {TutoElixirKBRW, []}
  ]
end
```

You can use `:httpc` as follows: 

``` elixir
{:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} =
  :httpc.request(:get, {'http://127.0.0.1:8098/buckets?buckets=true', []}, [], [])
```

---
**Exercice:**  

  * Create a **Riak** module able to query **Riak** through the **HTTP API** to be able to: 
    * get the list of buckets
    * get the list of key in a bucket 
    * get the object at a key of a bucket 
    * put in a bucket an object 
    * delete in a bucket an object 
  
*In Riak put an object at a key that already exist is equivalent to update this object.*

---
## Step 3 - Create a schema and index for research

In **Riak**, you need to index your data via an index based on a schema to be 
able to sort your data in the database.  
To store it, you need to create a schema like the one in the folder `riak/`.  
   
_You can get more infos inside the [Riak doc](https://docs.riak.com/riak/kv/2.2.3/configuring/search/), and [Solr doc](https://lucene.apache.org/solr/guide/6_6/)._  
  
**You can find an example of schema inside the `riak` folder.**  
  
Let's describe some fields of the schema:  
* **`field`** tag is the JSON field of your data that will be indexed. For instance
here, the field `id` is indexed. All `field` tag should be contained in the 
`<fields></fields>` tags.
  * **`name`** is the title of the field in your JSON. If your field is indented, 
  you should put a `.` to separate the parent field from the child one like for
  `custom.customer.email`. 
  * **`type`** is the type of data stored in your indexed value. These types are 
  defined later by the tag `fieldType`
  * **`indexed`** and `stored` should always be set as true (you can have a look to 
  the **Solr** documentation if you want to know more about these fields). 
  * **`multiValued`** indicates that your field can contain a list of item and 
  **Solr** should extend its research on all sub-field of your field.
* **`_yz_*`** fields are mandatory fields. They don't have to be represented in 
your JSON fields. They are created by **Solr** when your data are indexed. 
* **`uniqueKey`** tag is also a mandatory tag for **Solr** to retreive its indexed 
data
* **`fieldType`** tag is a declaration of a new index type usable in the `type` 
field of the `field` tag. They should be declared between the tags 
`<types></types>`
  * **`name`** is the name of your new type
  * **`class`** is the **Solr** class on which your type is based. Often we
  declare the common type defined in the documentation.

  
Once you schema is correctly defined you should be able to upload it on your riak server, with the correct [query](http://docs.basho.com/riak/kv/2.2.3/developing/api/http/store-search-schema/).  
  
Of course you can use `curl` to reach the Riak API
``` bash 
curl -XPUT http://localhost:8098/search/schema/order \
-H "Content-Type: application/xml" \
--data-binary @order_schema.xml
```
  
Now you can [create](http://docs.basho.com/riak/kv/2.2.3/developing/api/http/store-search-index/) your index based on your schema and [assign](http://docs.basho.com/riak/kv/2.2.3/developing/api/http/set-bucket-props/) your index to your bucket.  
Remember that if you want to put a different index to your bucket, or remove your index, first you will need to remove the `props` of your bucket.  
  
**Remember that value added BEFORE the index is set on your bucket ARE NOT indexed and should be updated (delete and add again).**  
  
---
**Exercice:**  
  * Create your own schema with fields that you want to filter your data with (for example customer's `full_name`) and add to your **Riak** module the following functions: 
    * upload a schema
    * create an index 
    * assign an index to a bucket
    * update a bucket (re set all the element in the bucket)
    * delete a bucket


---
## Step 4 - Uploading the JSON

---
**Exercice:**
  * Adapt the JSON loader your created for the **ETS** table to upload the orders to **Riak**
    * Use the [`Task`](https://hexdocs.pm/elixir/Task.html) processes and [`Stream`](https://hexdocs.pm/elixir/Stream.html) to parallelize the upload of your orders.
    * You will need to chunk your data in multiple blocks, and assign this blocks to each `Task`

_Be careful about the number of Tasks, you don't want to hit your **Riak** server too hard. 10 is a good number._  

---

## Step 5 - Search in your bucket

To make a query on an index, you need to use the following query: 

    http://localhost:8098/search/query/<index>/?wt=json&q=<query>

In the query above, `<query>` should be replaced by a **Lucene query**. The lucene 
documentation is available [here](http://www.lucenetutorial.com/lucene-query-syntax.html).  
  
If the search schema and index were correctly created and you linked properly the bucket to the index and then updated your bucket, you should be able to process the following query. 

    http://127.0.0.1:8098/search/query/order/?wt=json&q=type:"nat_order"

  
In **Riak** there is some additionnal parameters you can add to fetch a 
correct amount of data and sort your data:
* `start` the first key index to be returned 
* `rows` the number of keys in the returned result set 
* `sort` the field in your schema on which the sort will take place

A complete documentation is available [here](http://docs.basho.com/riak/kv/2.2.3/developing/usage/search/)

---
**Exercise:**  
  * Add to your **Riak** module a function able to search data according to a certain query were the signature of the function should be:

``` elixir
    def search(index, query, page \\ 0, rows \\ 30, sort \\ "creation_date_index")
```

  * Change your REST Api on your Elixir server to fetch data from **Riak** instead of the **ETS Table**
    * Remove the path `/api/search`, we should be able to fetch / search orders using `/api/orders`
    * We should be able to precise key / value couple like this
      * _Example: `/api/orders?page=0&rows=45&type=nat_order&id=nat_order45678765`_
  * Make it so that we can search inside your index by entering 'lucene like' queries inside the **Search** functionality of your `orders` page.
    * _Example: `type=nat_order&id=nat_order000234`_
  * We should be able to use the **Page selectors** at the bottom of you `orders` page to navigate inside **Riak**:
    * By Default, display 30 rows by page.
    * Clicking on the page number `2` should in reality only change the page argument of your `Riak.search/5`, fetch the new data, and re-render your front.

---
## Question time !

* Why do we use **Riak** over **ETS** ?
* What is **Solr** ?
* Do you know what a `dynamic fields` is ? When can it be useful ?
* What are the `_yz_*` fields ?

---
[Prev Chapter](chap5.html) **Chapter 6** [Next Chapter](chap7.html)

# Chapter 5 - React and Remote props

In this chapter, we will put our web app on a server with **Elixir**. We will 
modify the architecture of our **React** application to be able to load 
data from the server, **without** reloading all the pages (asynchronous call).  
  
This chapter is one of the hardest to understand, as it forces you to create a Web App as we do it in KBRW. There are other ways, but experience taught us this architecture.  
  
_If you have any question, please ask in the #formation channel._

## Step 0 - Put the React front on the server.

Remember [**Chapter 2**](chap2.html) ? Well we're gonna use our `Plug.Router` again :)  
  
Until now, to test if our front was working, we were loading the `index.html` file in `./priv/static`.  
We will change that, and tell our router where to go fetch it.  
  
First, we need to use a macro that will return our files in `/priv/static` on a 
**URL**.  
For that, we will use the [**`Plug.Static`**](https://hexdocs.pm/plug/Plug.Static.html) module.  
  
_As always, go read some of the documentation :)_  
  
``` elixir
plug Plug.Static, from: "priv/static", at: "/static"
```
  
Then, we need to return our `index.html` on calls that don't match a correct route. 
  
``` elixir
get _, do: send_file(conn, 200, "priv/static/index.html")
```
  
_That way, when the user will not interact with our **REST api**, he will be directed to our front page._  
  
Finally, we need to change the paths to js scripts and css in `index.html` to correspond to the path in our server (`/static/styles.css` for instance).  
  
Let's launch our project and go to the root url: 
[localhost:4001](http://localhost:4001)

---

![orders_page](img/orders_page.png)

---

## Step 1: Understand the architecture

The objective of this part is to be able to render the **HTML** items depending on the route of the page, without having to reload the page and retreive information from an API, to load dynamically the information.  
  
Do not forget that all our JS is executed **Client side**, this means that this code lives inside your client browser.  
For now only the API is server side.  
  
_**All our Elixir code is Server side, the rest is Client Side.**_
  
![schema_simplified_remote_props](./img/simplified_remote_props.png)
  
  
  * We're gonna listen to url change events, and when it occurs verify that the new route exists. For that we're gonna create a `routes` object, containing the list of available routes and various details about them (properties, data). 
  * Using our `route` data, we verify that all the needed data (`remoteProps`) are downloaded form the API.
    * If not we download them using our `remoteProps` object
    * Then we add them to the `props`, [the inner state of our React components.](https://reactjs.org/docs/components-and-props.html)
  * Finally, we display all the elements needed by the requested `route`

## Step 2 - Write the front architecture

### Dependencies

We're gonna have to add some new dependencies, to help us parse [Query Parameters](https://en.wikipedia.org/wiki/Query_string), Cookies, etc.   
```js
    "when": "^3.7.8",
    "xhr2": "^0.1.4",
    "cookie": "~0.1.2",
    "qs": "~2.3.3",
```

### Event Listener

Let's create our `onPathChange` function and add an event listener to it.  
You can see more about the `popstate` event [here](https://developer.mozilla.org/fr/docs/Web/Events/popstate).  

```js
function onPathChange() {
  ReactDOM.render(<Page />, document.getElementById('root'));
}

window.addEventListener("popstate", ()=>{ onPathChange() })
onPathChange()
```

### Parse our requested route
  
Now let's get the property of our new page (path, query string and cookie). 
  
Don't forget to import query string and cookie JS library:

```js
var Qs = require('qs')
var Cookie = require('cookie')
```

And then modify your `onPathChange` function.  
Here we're gonna retrieve the requested path and various parameters using the [location object](https://www.w3schools.com/jsref/obj_location.asp).  

```js
function onPathChange() {
  var path = location.pathname
  var qs = Qs.parse(location.search.slice(1))
  var cookies = Cookie.parse(document.cookie)

  ReactDOM.render(<Page />, document.getElementById('root'));
}
```
  
Now we will declare a global variable that will describe the state of our browser.  
It will become the [props](https://reactjs.org/docs/components-and-props.html) given to our **React** components.  

``` javascript
var browserState = {}

function onPathChange() {
  [...]
  var cookies = Cookie.parse(document.cookie)

  browserState = {
    ...browserState, 
    path: path, 
    qs: qs, 
    cookie: cookies
  }
  [...]
}
```

### The routes object

Let's create a `routes` object. It's gonna tell us which React component you have to display depending on the requested route.  
  
_We will use the path `/` for the orders list page and `/order/<order_id>` for the order we want to know more about._

```js
var routes = {
  "orders": {
    path: (params) => {
      return "/";
    },
    match: (path, qs) => {
      return (path == "/") && {handlerPath: [Layout, Header, Orders]}
    }
  }, 
  "order": {
    path: (params) => {
      return "/order/" + params;
    },
    match: (path, qs) => {
      var r = new RegExp("/order/([^/]*)$").exec(path)
      return r && {handlerPath: [Layout, Header, Order],  order_id: r[1]}
    }
  }
}
```

  * The first part of our return try to match the path. If it's true we return an object containing data about the React components, and the props.
  * `HandlerPath` contains the list of React components to render
  
To use this, we need to define the **React Classes** `Layout` (here our layout is empty and will be build later), `Header` (The header of our website), `Orders` (the page with the orders list) and `Order` (the page with the order description).  
  
### Render our components

To render the components present inside `handlerPath`, we're gonna create a new React class named **Child** that will render the others recursively.  

_It is just gonna render the requested component with the rest of the list. This ChildHandler component is gonna have to do the same thing._  

```js
var Child = createReactClass({
  render(){
    var [ChildHandler,...rest] = this.props.handlerPath
    return <ChildHandler {...this.props} handlerPath={rest} />
  }
})
```

With these new objects (`routes` and `Child`), we can now update our `onPathChange` function to print 
the correct object depending on the route.  
  
_If you dont understand where we are going, go take another look at the diagram above_
    
```js
var browserState = {Child: Child}

function onPathChange() {
  [...]
  browserState = {...}
  var route, routeProps
  //We try to match the requested path to one our our routes
  for(var key in routes) {
    routeProps = routes[key].match(path, qs)
    if(routeProps){
        route = key
          break;
    }
  }
  browserState = {
    ...browserState,
    ...routeProps,
    route: route
  }
  //If we don't have a match, we render an Error component
  if(!route)
    return ReactDOM.render(<ErrorPage message={"Not Found"} code={404}/>, document.getElementById('root'))
  ReactDOM.render(<Child {...browserState}/>, document.getElementById('root'))
}
```
  
At this point only your empty `Layout` component is printed.  
Indeed, the `Child` class only render the first class, you need to modify the other components to call `Child` on your child class list. 

```js
var Layout = createReactClass({
render(){
  return <JSXZ in="orders" sel=".layout">
      <Z sel=".layout-container">
        <this.props.Child {...this.props}/>
      </Z>
    </JSXZ>
  }
})
```
  
This is creating a tree of component **with only one branch**.  
It's gonna allow us to modify the props of our `Layout` and propagate them to the others really easily.

---

**Exercice:**

Create the different **React** classes that will compose our application: `Header`, `Orders`, `Order`.  
Our layout will have a `.layout` CSS class, our header a `.header-container`, etc.  
As we want to have a **one branch tree**,  our Layout `div` will contain our header `div`, that will contain our container `div`. Modify your Webflow accordingly.  
```
  Layout
    |- Header
        |- Orders
```

---
## Step 3: Download the remoteProps from the API

Now that our front is structured, we want to download the information from our server API.  

### HTTP requests

If we want to fetch information from our API, we will need to make **HTTP** call to our **`Server.Router`**.  
So, we will add a **`HTTP`** module to send the requests. 

```js
var XMLHttpRequest = require("xhr2")
var HTTP = new (function(){
  this.get = (url)=>this.req('GET',url)
  this.delete = (url)=>this.req('DELETE',url)
  this.post = (url,data)=>this.req('POST',url,data)
  this.put = (url,data)=>this.req('PUT',url,data)

  this.req = (method,url,data)=> new Promise((resolve, reject) => {
    var req = new XMLHttpRequest()
    req.open(method, url)
    req.responseType = "text"
    req.setRequestHeader("accept","application/json,*/*;0.8")
    req.setRequestHeader("content-type","application/json")
    req.onload = ()=>{
      if(req.status >= 200 && req.status < 300){
      resolve(req.responseText && JSON.parse(req.responseText))
      }else{
      reject({http_code: req.status})
      }
    }
  req.onerror = (err)=>{
    reject({http_code: req.status})
  }
  req.send(data && JSON.stringify(data))
  })
})()
```
  
Take some time to understand this code. If you don't know what a `Promise` is, take a look at this article my Mozilla: [here](https://developer.mozilla.org/fr/docs/Web/JavaScript/Guide/Utiliser_les_promesses).  
  
  ### Our remoteProps object

Let's create the `remoteProps` object that will contains the URL of the API to request to obtain the data (prop), as well as the name of this prop.  

```js
var remoteProps = {
  user: (props)=>{
    return {
      url: "/api/me",
      prop: "user"
    }
  },
  orders: (props)=>{
    if(!props.user)
      return
    var qs = {...props.qs, user_id: props.user.value.id}
    var query = Qs.stringify(qs)
    return {
      url: "/api/orders" + (query == '' ? '' : '?' + query),
      prop: "orders"
    }
  },
  order: (props)=>{
    return {
      url: "/api/order/" + props.order_id,
      prop: "order"
    }
  }
}
```

  * `orders` links to the API call to get the list of orders in our **ETS database**
  * order will return a **JSON** containing 1 item for the order description page.
  * I added here the `user` prop. This prop represent an authentication props. This is just here to expose **the mechanism of dependencies** between props
    * _Here the `orders` props depends on the `user` props._
  
_You can comment the code relative to the user props if need be_  
  
Let's add the corresponding remoteProps to our **React Classes** as a [static property](https://stackoverflow.com/questions/29433130/react-statics-with-es6-classes).  

```js
var Orders = createReactClass({
  statics: {
    remoteProps: [remoteProps.orders]
  },
  [...]
}
```
  
The original props of our **React** classes are based on the variable `browserState`, we will download in it the value required from the API, based on our remote props.  
For that we will create a function `addRemoteProps`. This function will take as parameters the `browserState` (our `props`) and modify it to add the result of the API.  
The `API endpoints` to request can be accessed at `browserState.handlerPath[i].remoteProps[j]`  
  
Our function will be asynchronous, so we will use [Promise](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Objets_globaux/Promise).  

---
```js
function addRemoteProps(props){
  return new Promise((resolve, reject)=>{
```
*As our function call for nework data, we need to create a `Promise` that will resolve when all the 
API call will resolve*  
  
---
```js
    //Here we could call `[].concat.apply` instead of `Array.prototype.concat.apply`
    //apply first parameter define the `this` of the concat function called
    //Ex [0,1,2].concat([3,4],[5,6])-> [0,1,2,3,4,5,6]
    // <=> Array.prototype.concat.apply([0,1,2],[[3,4],[5,6]])
    //Also `var list = [1,2,3]` <=> `var list = new Array(1,2,3)`
    var remoteProps = Array.prototype.concat.apply([],
      props.handlerPath
        .map((c)=> c.remoteProps) // -> [[remoteProps.user], [remoteProps.orders], null]
        .filter((p)=> p) // -> [[remoteProps.user], [remoteProps.orders]]
    )
```
*Here we extract from the `browserState` the `remoteProps` function that return the url and the 
`prop name`.*  
  
---
```js
    var remoteProps = remoteProps
      .map((spec_fun)=> spec_fun(props) ) // -> 1st call [{url: '/api/me', prop: 'user'}, undefined]
                                // -> 2nd call [{url: '/api/me', prop: 'user'}, {url: '/api/orders?user_id=123', prop: 'orders'}]
      .filter((specs)=> specs) // get rid of undefined from remoteProps that don't match their dependencies
      .filter((specs)=> !props[specs.prop] ||  props[specs.prop].url != specs.url) // get rid of remoteProps already resolved with the url
    if(remoteProps.length == 0)
      return resolve(props)
```
*On the code above, we execute the `remoteProps` functions and if it return a not correct object (`undefined`) or if the `props` has already been resolved with the same URL, then we remove these
object from the list.  
This behavior can be used to implement dependencies in the `remoteProps` as we will see later with the `/me/api` route*  

**Take your time to fully understand what this piece of code does**  
  
---
```js
    // check out https://github.com/cujojs/when/blob/master/docs/api.md#whenmap and https://github.com/cujojs/when/blob/master/docs/api.md#whenreduce
    var promise = When.map( // Returns a Promise that either on a list of resolved remoteProps, or on the rejected value by the first fetch who failed 
      remoteProps.map((spec)=>{ // Returns a list of Promises that resolve on list of resolved remoteProps ([{url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}])
        return HTTP.get(spec.url)
          .then((result)=>{spec.value = result; return spec}) // we want to keep the url in the value resolved by the promise here. spec = {url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'} 
      })
    )

    When.reduce(promise, (acc, spec)=>{ // {url: '/api/me', value: {name: 'Guillaume'}, prop: 'user'}
      acc[spec.prop] = {url: spec.url, value: spec.value}
      return acc
    }, props).then((newProps)=>{
      addRemoteProps(newProps).then(resolve, reject)
    }, reject)
  })
}
```
*Finally, with the `When` library, we launch all the remote props download, and once the all the promise are resolved, the `When` tool will call the function `addRemoteProps` with the new list of 
remote props (and if all the props are resolved, the Promise addRemoteProps will resolve).*  
**Go take a look at the [When](https://github.com/cujojs/when) library.**  
  
Don't forget to import it:  
  
```js
var When = require('when')
```
  
---
  
I summarized the way `addRemote` works in the follwing schema:  

![add_remote_props](./img/add_remote_props.png)

Now we can call this promise and wait for its resolution in the `onPathChange` function 

``` javascript
function onPathChange() {
  [...]
  addRemoteProps(browserState).then(
    (props) => {
      browserState = props
      //Log our new browserState
      console.log(browserState)
      //Render our components using our remote data
      ReactDOM.render(<Child {...browserState}/>, document.getElementById('root'))
    }, (res) => {
      ReactDOM.render(<ErrorPage message={"Shit happened"} code={res.http_code}/>, document.getElementById('root'))
    })
}
```

**Really take your time to fully understand how we fetch our remote props**

### A little utility to change pages
  
We mostly use the `history` object of the browser to change the `URL`.  
Here is a minimalist implementation of a function that allows us to change the page the user is in:
```js
var GoTo = (route, params, query) => {
  var qs = Qs.stringify(query)
  var url = routes[route].path(params) + ((qs=='') ? '' : ('?'+qs))
  history.pushState({}, "", url)
  onPathChange()
}
```
  
**I will let you find where to put this function so that you can use it from all your React components.**  
  

### Link it to our ETS table

We now have a front that fetch data from our **Elixir** server, and display **React** components.  
Let's link all that with our ETS table :)  

---
**Exercices:**  

  * Adapt your REST api so that it can respond to the path requested by the `remoteProps` object
    * It must return a list of all orders when requesting the `/api/orders`. Take some time to understand the line about `var qs = {...}` and the `query`
    * When requesting `/api/order/order_id`, it must return a JSON representing the order with the id `order_id`.
  * Render the data on your front using **React** and **JSXZ**. Adapt your webflow if need be.
  * When clicking on the `view` button in your `orders` page, it must go to your `order` page and show us the details of the requested order.  
  
**Take your time, this exercice can take you some time to solve**  

---

## Step 4 - Cool, cool, but why the eck did we create modals and loaders ?

 ### The risky delete operation

By now you should be comfortable with the remote props and the mechanism to fetch them.  
We will now add a new functionality to our front: the **delete** operation.  
  
This operation can be dangerous, so when our user is gonna want to use it, we **need** him to **confirm** it. To do that, we're gonna use **modals**.  

Here are the steps that we're gonna follow:  
  * Create a confirmation modal in Webflow. Don't forget: **one modal, one page**. Create a new project in Webflow if need be. _In the premium version you can create as much pages as you need by project, don't worry_
    * Add it the `hidden` class by default
  * When our design is done, we need to add it to our **React** application  
    * Let's see how we're gonna display / hide our modal
      * The user clicks on the `delete` button
      * We **remove** the `hidden` css class from the modal
      * The user confirms, or not
      * We **add** the `hidden` css class to our modal
    * Upon confirmation, or deletion, we need to get the information back and process or not the deletion
  
  
I'm gonna go over it step by step.  
  
We will use the advantages of our **tree with one branch**. We will create an utility function inside our `Layout` component to display the modal, and propagate the `props` down to all our other components.  
This utility function will have one parameter: an object with various data about the modal to be displayed and the callback function to call with the result.  
  
Here is our `modal` function, to add to our `Layout` React class.  
```js
  modal(spec){
    this.setState({modal: {
      ...spec, callback: (res)=>{
        this.setState({modal: null},()=>{
          if(spec.callback) spec.callback(res)
        })
      }
    }})
  }
```
  
_We deactivate our modal upon completion of its work, BEFORE the callback. This allow us to keep our environment under control, as we do not know what the user might do inside its callback function._  
  
The `setState` function here is really important: [doc](https://reactjs.org/docs/react-component.html#setstate).  
It allows us to change the **state** of our `Layout` component **AND** triggers a new rendering.  
  
**This is changing the STATE of the components, not its PROPS. You can lean more about it in the [React documentation](https://reactjs.org/docs/faq-state.html) or [here](https://github.com/uberVU/react-guide/blob/master/props-vs-state.md).**  

_You will want to take a look at [this](https://reactjs.org/docs/react-without-es6.html) to initialize your **state**._  

As it triggers a new rendering, we need to tell React to render our modal when the props `modal` is defined.  
To display our modal, we said earlier that we need to remove the `hidden` CSS class.  
To do that we're gonna use the **JSX** option `className`.  

This function allows us to **conditionaly** add / remove a CSS class to our `div`.  
```js
  <Z sel=".modal-wrapper" className={cn(classNameZ, {'hidden': !modal_component})}>
  {modal_component}
  </Z>

```
  
The `cn` function here refers to this one:
```js  
  var cn = function(){
    var args = arguments, classes = {}
    for (var i in args) {
      var arg = args[i]
      if(!arg) continue
      if ('string' === typeof arg || 'number' === typeof arg) {
        arg.split(" ").filter((c)=> c!="").map((c)=>{
          classes[c] = true
        })
      } else if ('object' === typeof arg) {
        for (var key in arg) classes[key] = arg[key]
      }
    }
    return Object.keys(classes).map((k)=> classes[k] && k || '').join(' ')
  }
```
_This basically just aggregates the current CSS classes of your object (classNameZ) with the new one depending on boolean conditions_  
  
Here `modal_component` is the **React Class** of our modal, deduced from the data contained inside `this.state.modal`.  
  
We need to declare this variable in our `render()` function, before returning the `JSXZ` balise.  
Our architecture should look something like this now:    
```js
Layout = React.createClass({
  statics: ...
  modal(modal_data) {
    ...
  },
  render(){
    var modal_component = ... //Deduced from this.state.modal
    ...
    return <JSXZ ...>
      ...
      <Z sel=".modal-wrapper" className={cn(classNameZ, {'hidden': !modal_component})}>
        {modal_component}
      </Z>
      ...
    </JSXZ>
  }
})
```
_Take your time to understand how the `className` attribute works, test it on your own a little!_  
  
Let's now create a **React Class** based on our **modal template**.    
  
```js
var DeleteModal = React.createClass({
  render(){
    //Render your modal here.
  }
})
```
  
Our `var modal_component` becomes:
```js
  var modal_component = {
      'delete': (props) => <DeleteModal {...props}/>
  }[this.state.modal && this.state.modal.type];
  modal_component = modal_component && modal_component(this.state.modal)
```
_The `type` attribute of our modal will be the name of the modal to render, here `delete`._  
  
This way your user can pass any data he wants to your modal, as we are forwarding the whole `this.state.modal` object as props to the `DeleteModal`.  
  
Know we can use our **one branch tree**, and add our `modal` function to the props before calling our **Child** component.  
```js
 var props = {
      ...this.props, modal: this.modal
 }
 ...
  <this.props.Child {...props}/>
...
```
  
We can now call our `modal` function from one of our child components, say `Orders`.  
  
```js
    this.props.modal({
        type: 'delete',
        title: 'Order deletion',
        message: `Are you sure you want to delete this ?`,
        callback: (value)=>{
          //Do something with the return value
        }
      })
```
_Here we have a generic Yes/No modal that renders a different title / message depending on its props._  
  
---
**Exercice:**  
  * Create your confirmation modal in Webflow
  * Add a `delete` button to your table lines in your `orders` page
  * When clicking on this button, your web app should send a request to the REST Api and delete the selected order.  
  * You will have to add a system to force reload the remote props of your orders, to trigger a re-rendering.

_You will want to add a `div` with the css class `modal-wrapper` inside your `orders` page. We will use JSX to inject in it our modal from our `modal` page._  

---

### Background operation, or why use our beautiful loader
  
When your front asks for remote props, the latency of your action is dependant of the reactivity of your server. This means that you may not receive the information you want instantly.  
However, the user of your web app **must always know what is happening**. That means that when you are fetching information in your back-end, **you must tell** by some way to your user that you are processing and waiting.  
To do that, we're gonna use **loaders**.  
  
The logic of the loader is the same as of our modal, the difference is that your callback is gonna perform an asynchronous action. That means that we will use **Promises**.  
  
The rendering of our loader will be much more simpler than our modal, as we only need to store a true / false state in our props to know if we need to display it.  
  
---
**Exercice:**  
  * Using the knowledge your acquired creating your first modal, create a `loader` function inside the `Layout` React class.
    * The function **must** return a new **Promise**.
    * The function **must** take in parameter a **Promise** to execute.
  * Add to your `Layout` render function the ability to render your loader.
  * Make it so that you can call your `loader` function from any child components of `Layout`
  * Improve your delete order function to use the `loader`
  
From now on, use the `loader` on all your operations that perform a remote props fetch.  
  
---
## Question time !

* Why import the library "xhr2" for our `HTTP` object
* Why not use the `fetch` functionality of JS instead ?
* Why do we use `qs` for ?
* What is **React** ?
* What is a **Promise** ?

---
[Prev Chapter](chap4.html) **Chapter 5** [Next Chapter](chap6.html)

require('!!file-loader?name=[name].[ext]!./index.html')
/* required library for our React app */
var React = require("react")
var ReactDOM = require('react-dom')
var createReactClass = require('create-react-class')
var Qs = require('qs')
var Cookie = require('cookie')
var When = require('when')
var localhost = require('reaxt/config').localhost

/* required css for our application */
require('../webflow/css/orders.css');
require('../webflow/css/order.css');
require('../webflow/css/modal.css');
require('../webflow/css/loadder.css');

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

var XMLHttpRequest = require("xhr2")
var HTTP = new (function(){
  this.get = (url)=>this.req('GET',url)
  this.delete = (url)=>this.req('DELETE',url)
  this.post = (url,data)=>this.req('POST',url,data)
  this.put = (url,data)=>this.req('PUT',url,data)

  this.req = (method,url,data)=> new Promise((resolve, reject) => {
    var req = new XMLHttpRequest()
    url = (typeof window !== 'undefined') ? url : localhost+url
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

function addRemoteProps(props){
  return new Promise((resolve, reject)=>{
    var remoteProps = Array.prototype.concat.apply([],
      props.handlerPath
        .map((c)=> c.remoteProps) // -> [[remoteProps.user], [remoteProps.orders], null]
        .filter((p)=> p) // -> [[remoteProps.user], [remoteProps.orders]]
    )
    var remoteProps = remoteProps
    .map((spec_fun)=> spec_fun(props) ) // -> 1st call [{url: '/api/me', prop: 'user'}, undefined]
                              // -> 2nd call [{url: '/api/me', prop: 'user'}, {url: '/api/orders?user_id=123', prop: 'orders'}]
    .filter((specs)=> specs) // get rid of undefined from remoteProps that don't match their dependencies
    .filter((specs)=> !props[specs.prop] ||  props[specs.prop].url != specs.url) // get rid of remoteProps already resolved with the url
    if(remoteProps.length == 0)
      return resolve(props)

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

var remoteProps = {
  user: (props)=>{
    return {
      url: "/api/me",
      prop: "user"
    }
  },
  orders: (props)=>{
    // if(!props.user)
    //   return
    // var qs = {...props.qs, user_id: props.user.value.id}
    var qs = {...props.qs}
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

var GoTo = (route, params, query) => {
  var qs = Qs.stringify(query)
  var url = routes[route].path(params) + ((qs=='') ? '' : ('?'+qs))
  history.pushState({}, "", url)
  onPathChange()
}

var Child = createReactClass({
  render(){
    var [ChildHandler,...rest] = this.props.handlerPath
    return <ChildHandler {...this.props} handlerPath={rest} />
  }
})

var Layout = createReactClass ({

  getInitialState: function() {
    return {
      modal: null,
      loader: false,
    };
  },


  modal(spec){
    this.setState({
      modal: {
        ...spec, callback: (res)=>{
          this.setState({modal: null},()=>{
            if(spec.callback) spec.callback(res)
          })
        }
      }
    })
  },

  loader(promise) {
    this.setState({loader: true});
    return promise.then(() => {
      this.setState({loader: false});
    })
  },

  render(){
    var modal_component = {
      'delete': (props) => <DeleteModal {...props}/>
    }[this.state.modal && this.state.modal.type];
    modal_component = modal_component && modal_component(this.state.modal)

    var loader_component = this.state.loader && (() => <Loader />)
    loader_component = loader_component && loader_component(this.state.loader)


    var props = {
      ...this.props, modal: this.modal, loader: this.loader
    }



    return <JSXZ in="orders" sel=".layout">
        <Z sel=".layout-container">
          <this.props.Child {...props}/>
        </Z>
        <Z sel=".modal-wrapper" className={cn(classNameZ, {'hidden': !modal_component})}>
          {modal_component}
        </Z>
        <Z sel=".loadder-wrapper" className={cn(classNameZ, {'hidden': !loader_component})}>
          {loader_component}
        </Z>
      </JSXZ>
  }
})

var Loader = createReactClass({
  render() {
    return <JSXZ in="loadder" sel=".loader">
    </JSXZ>
  }
})

var DeleteModal = createReactClass({
  render(){
    return <JSXZ in="modal" sel=".modal">
        <Z sel=".title">{ this.props.title }</Z>
        <Z sel=".message">{ this.props.message}</Z>
        <Z sel=".button-cancel" onClick={() => this.props.callback(false)}><ChildrenZ /></Z>
        <Z sel=".button-validate" onClick={() => this.props.callback(true)}><ChildrenZ /></Z>
    </JSXZ>
  }
})

var Header = createReactClass({
  render(){

    return <JSXZ in="orders" sel=".header">
        <Z sel=".header-container">
          <this.props.Child {...this.props}/>
        </Z>
      </JSXZ>
  }
})


var Order = createReactClass({
  statics: {
    remoteProps: [remoteProps.order]
  },
  render(){
    const order = this.props.order.value
    const items = order.custom.items
    let total_quantity = 0
    let total_price = 0
    let total_unit_price = 0
    items.forEach(item => {
      total_quantity += item.quantity_to_fetch
      total_unit_price += item.unit_price
      total_price += item.quantity_to_fetch * item.unit_price
    });
    return <JSXZ in="order" sel=".container">
        <Z sel=".order-name">{order.custom.customer.full_name}</Z>
        <Z sel=".order-address">{order.custom.shipping_address.street[0] + ", " + order.custom.shipping_address.postcode + " " + order.custom.shipping_address.city}</Z>
        <Z sel=".order-id">{order.id}</Z>
        <Z sel=".table-body">
        {
          items.map((item, i) => (
            <JSXZ key={i} in="order" sel=".table-order-info-body">
              <Z sel=".table-order-info-body-name">{item.item_id}</Z>
              <Z sel=".table-order-info-body-unit-price">{item.unit_price}</Z>
              <Z sel=".table-order-info-body-quantity">{item.quantity_to_fetch}</Z>
              <Z sel=".table-order-info-body-total-price">{item.unit_price * item.quantity_to_fetch}</Z>
            </JSXZ>
            ))
        }
        </Z>
        <Z sel=".total-price">{total_price}</Z>
        <Z sel=".total-quantity">{total_quantity}</Z>
        <Z sel=".total-unit-price">{total_unit_price}</Z>
      </JSXZ>
  }
})

var Orders = createReactClass({
  statics: {
    remoteProps: [remoteProps.orders]
  },

  modal (id) {

    this.props.modal({
      type: 'delete',
      title: 'Order deletion',
      message: `Are you sure you want to delete this ?`,
      callback: (value)=>{
        if (value) {
          this.props.loader(
              HTTP.delete('/api/order/' + id)
            ).then(() => {
              delete browserState.orders;
              onPathChange();
            })
        }
      }
    })  
  },

  render(){

    return <JSXZ in="orders" sel=".container">
      <Z in="orders" sel=".table-body">
        {
          this.props.orders.value.map((order, i) => (<JSXZ key={i} in="orders" sel=".line-1">
            <Z sel=".id">{order.id}</Z>
            <Z sel=".customer">{order.custom.customer.full_name}</Z>
            <Z sel=".address">{order.custom.shipping_address.street[0] + ", " + order.custom.shipping_address.postcode + " " + order.custom.shipping_address.city}</Z>
            <Z sel=".quantity">{order.custom.items.length}</Z>
            <Z sel=".id">{order.id}</Z>
            <Z sel=".div-block-2" onClick={() => GoTo("order", order.id, "")}><ChildrenZ/></Z>
            <Z sel=".status">Status: {order.status.state}</Z>
            <Z sel=".trash" onClick={() => this.modal(order.id)}><ChildrenZ /></Z>
          </JSXZ>))
        }
     </Z>
    </JSXZ>
  }
})

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

var browserState = {Child: Child}

function onPathChange() {
  var path = location.pathname
  var qs = Qs.parse(location.search.slice(1))
  var cookies = Cookie.parse(document.cookie)

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
  addRemoteProps(browserState).then(
    (props) => {
      browserState = props
      //Log our new browserState
      //Render our components using our remote data
      ReactDOM.render(<Child {...browserState}/>, document.getElementById('root'))
    }, (res) => {
      ReactDOM.render(<ErrorPage message={"Shit happened"} code={res.http_code}/>, document.getElementById('root'))
    })
}

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
  },

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
})

window.addEventListener("popstate", ()=>{ onPathChange() })
onPathChange()

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
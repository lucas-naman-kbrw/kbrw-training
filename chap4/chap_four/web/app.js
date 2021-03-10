require('!!file-loader?name=[name].[ext]!./index.html')
/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')

/* required css for our application */
require('./webflow/css/orders.css');
require('./webflow/css/order_info.css');

var orders = [
  {remoteid: "000000189", custom: {customer: {full_name: "TOTO & CIE"}, billing_address: "Some where in the world"}, items: 2}, 
  {remoteid: "000000190", custom: {customer: {full_name: "Looney Toons"}, billing_address: "The Warner Bros Company"}, items: 3}, 
  {remoteid: "000000191", custom: {customer: {full_name: "Asterix & Obelix"}, billing_address: "Armorique"}, items: 29}, 
  {remoteid: "000000192", custom: {customer: {full_name: "Lucky Luke"}, billing_address: "A Cowboy doesn't have an address. Sorry"}, items: 0}, 
]

var Page = createReactClass( {
  render(){
      <JSXZ in="orders" sel=".line-1">
        <Z sel=".div-block-6">{orders[0].remoteid}</Z>
        <Z sel=".div-block-5">{orders[0].custom.full_name}</Z>
        <Z sel=".div-block-4">{orders[0].custom.billing_address}</Z>
        <Z sel=".div-block-3">{orders[0].items}</Z>
      </JSXZ>

    return <JSXZ in="orders" sel=".container">
        <Z sel=".div-block-6">{orders[0].remoteid}</Z>
        <Z sel=".div-block-5">{orders[0].custom.full_name}</Z>
        <Z sel=".div-block-4">{orders[0].custom.billing_address}</Z>
        <Z sel=".div-block-3">{orders[0].items}</Z>
    </JSXZ>
  }
})
  
ReactDOM.render(<Page />, document.getElementById('root'));


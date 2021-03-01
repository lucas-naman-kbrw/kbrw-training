# Chapter 4: Your great friend, Webflow

The objective of this chapter is to familiarize yourself with [Webflow](https://webflow.com/), a tool we use to create beautiful and responsive front-end.  
This tool helps us do the **Design** part of our project.  Linked with **JSXZ** and **React** you can rapidly create web applications.  
  
## Step 0: Setting up Webflow

Before you go further, you need to create a free [Webflow](https://webflow.com/) account.  
[Webflow](https://webflow.com/) without a plan is restricted on some level. For example, you won't be able to create more than one page per project, or you won't be able to automatically export the resources of your project.

  ### Create your project 

Once logged in on your **Webflow** account, go to your dashboard and create a new project.  
Choose a  `Blank site` as starting point.  
  
You will be redirected to the `home` page of your project, where you can start your design.  
  
You can inspire yourself from other Webflow projects. 
  
  ### The components

You can find components in the left side of the page.  
Some of them are customs and specific to **Worflow**. This means that they use custom Webflow CSS classes, that we do not have control of.  
For this reason, we advise you to only use "raw" components.  
This includes: all the `Basic`, all the `Typography`, all the `Forms`, and all the `Media`. 
  
**[NOTAE SIMONAE]**  
Couple things to keep in mind when you build your website with webflow so the integration goes smoothly:  
- Always use classes on your DOM components (never ids). So don't hesitate to create as many specific classes you need: This will make the integration easier later.  

### Our container

All the items of our page will be contained inside **one** container, a `div`.  
Let's create it.  
  
_The default container of a page is the **`<body>`** tag. But, as we're gonna use **React** this is gonna make some trouble. Indead, **React** use the body tag to inject the generated page in it. Think about that when you will use your webflow generated page inside your web application._

![container](./img/container.png)

  ### Web page design

All our web applications use **React**, as well as the homemade library named **JSXZ**.  
  
As you already know, **JSXZ** is using what we call a **CSS selector**. This means that when rendering our web page, we will be able to target specific **CSS classes** to alter it and inject custom values.  
  
Knowing this will impact the way you are gonna design your page.  
So if we think about the architecture of a table it will have to look like that when we will want to inject values: 
```js
<JSXZ sel=".table">
  <Z sel=".tab-header"><ChildrenZ/></Z>
  <Z sel=".tab-body">
    <JSXZ sel=".line">{'Line 1'}</JSXZ>
    <JSXZ sel=".line">{'Line 2'}</JSXZ>
    <JSXZ sel=".line">{'Line 3'}</JSXZ>
    <JSXZ sel=".line">{'Line 4'}</JSXZ>
  </Z>
</JSXZ>
```
  
We can see that each lines as a specific **CSS class**, and it should also be the same for the columns if we want to inject values at specific positions inside a line.  

![table-header-archi](./img/table-header-archi.png)  

If we use the same thinking for our table body, we end up with something like this:  
  
![architecture](./img/table-architecture.png)
  
**All the CSS of our page is done via Webflow, DO NOT edit your CSS files with another editor.**
  
  ### Tips and tricks

 - The layout `Flex box` is really useful and allow you to center your content. It should be your default layout. You can change the layout of a specific component using the right panel on you web page.

![flex-panel](./img/flex-panel.png) 

  ### Font awesome

We will use the [**Font awesome**](https://fontawesome.com/) fonts for all the texts.  
   
Here are the steps to install them:
  - Download the fonts [here](https://fontawesome.com/how-to-use/on-the-web/setup/hosting-font-awesome-yourself)
  - Go you your [Webflow Dashboard](https://webflow.com/dashboard)
  - Go to the settings of your project
  - In the tab `Fonts` click on `Upload` and select all the fonts inside the folder `webfonts`
  - Validate every fonts 
  
To use it, you can for example select an icon from [this list](https://fontawesome.com/icons?d=gallery), copy the `glyph unicode` and paste it inside you Webflow.  
You should see a square. Change the fonts of this component to `Fa solid` and you should see your icon now :).  
  
_You should now be able to select the fonts like **Fa _something_** in your projects._

## Step 1: Design our pages

You will create a basic two-pages front-end:
  - The first page will:
    - Display a search box with a search button
    - Display a pagination at the bottom
      - The user must be able to go to the **First**, **-1**, **+1**, **Last** pages.
        - _Example_: `0 1 2 3` Will be displayed, where **2** is the current page, and there is just enougth data to be displayed on the 3rd.
    - Display an array containing all the orders: their command number, customer name, address, and the total quantity of items
    - On each line of the array there should also be a button to pay the order, and another to go to the order's details


  - The second page will:
    - Display the detail of an order: command number, customer name, address
    - Display a table of the content of the order: name, unit price, total price, quantity
    - Display the total price of the order
    - A return button to go back to the first page
  

**Take your time to do something good :)**  
**Use at least ONE Font Awesome icon.**  
  
_Some examples:_  

---

![orders_page](./img/orders_page.png)

---

![order_page](./img/order_page.png)

---

## Step 2: Download the templates 

Now that we have two beautiful pages, we want to download them in a `web` subdirectory of our mix project.  
  
To do so Webflow offers an export feature that allows you to download all your project resources in a zip file.  
Unfortunately, this feature is not available on a free plan. But we found a little alternative so that you can still do this training.  
  
Once your satisfied with your design, find the `Publish` button on the top-right corner of Webflow (you should see a little rocket icon there). Click on it, select the default webflow.io domain suggested and click on `Publish to Selected Domains`. Once it's done, just go on the domain you just published to.

![architecture](./img/webflow_publish.png)

On this page you can just manually download the resources of your projects and save them in the right place ;-)  
  
Example:  
if my domain is http://tuto.webflow.io/, you can just run in your project repo the following `curl` command to download the resources.

`curl http://tuto.webflow.io/ > web/tuto.webflow/orders.html`

`curl https://uploads-ssl.webflow.com/5ac7a945e4871d724363ff2f/css/tuto.webflow.1509436a0.css > web/tuto.webflow/csc/tuto.webflow.css`
_etc._
  
You'll have to do the same for every resources of your page.  
  
To know what you need, just check out in your Chrome inspector what your pages download.  

![architecture](./img/webflow_chrome_inspector.png)

Rest assured, we don't do that manually on our projects. We have a nice automated way to download webflow resources, that you'll find out when you'll start working with us.  
  
You should now have your two html pages as well as the corresponding resources inside your `web` subdirectory.

---

## Step 3: Link Webflow, React and JSXZ

Let's pack it all together ! :)

### Webpack

We're gonna modify our Webpack configuration a little:
  - Change the output directory
  - Bundle all our **CSS** inside one file
  
For that we first need to import two modules:
```js
  var ExtractTextPlugin = require("extract-text-webpack-plugin")
  var path = require('path')
```
_Add the necessary dependencies to your NPM project_
  
Here is the new configuration.  
```js
    //...
    //This will output our files inside the ../priv/static directory
    output: {
      path: path.resolve(__dirname, '../priv/static'),
      filename: 'bundle.js'
    },
    //...
    //This will bundle all our .css file inside styles.css
    plugins: [
        new ExtractTextPlugin ({
            filename: "styles.css"
        }),
      ],
    //...
    //Add to our loaders
    //This will process the .css files included in our application (app.js)
            {
                test: /\.css$/,
                use:  ExtractTextPlugin.extract({use: "css-loader"})
            }
```
  
To make Webpack aware of our files, we will need to `require` them inside our application.  
  
```js
require('!!file-loader?name=[name].[ext]!./index.html')
require('./tuto.webflow/css/tuto.webflow.css');
```
_I will let you have a look at the dependency file-loader and install it_

### The React web application

Rename your `script.js` into `app.js`, and remove everything inside it.  
Let's create the base of our React App:  

``` javascript
require('!!file-loader?name=[name].[ext]!./index.html')
/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')

/* required css for our application */
require('./tuto.webflow/css/webflow.css');
require('./tuto.webflow/css/tuto.webflow.css');
```

_You need to require your own resources, according to your webflow project and the css files your downloaded._  
  
Here we require all the needed library for our **React** application.  
Now we will write our custom React component using our **HTML** code:  

``` javascript
var Page = createReactClass( {
render(){
  return <JSXZ in="orders" sel=".container">
  </JSXZ>
}
})

ReactDOM.render(<Page />, document.getElementById('root'));
```
  
Here, the **`<JSXZ>`** tag tells to the transpiler to integrate all the content of the `.container` class of our **HTML** in the **React** class. This will print statically the content of our class on our page.  
  
Now execute **Webpack** script to transpile our page to `priv/static`
```sh
  $> node node_modules/webpack/bin/webpack.js
```
  
_Hint: you can use the `-w` option to tell webpack to watch over you files and transpile them when a modification occured._  
  
To verify our page is correctly generated, launch `./priv/static/index.html` in your bowser. Verify the whole page is correctly printed in your bowser.  
  
Let's now modify our script to load the data in our table.  
For that we will use the **`<Z>`** tag.  

### Integrate Webflow HTML with JSXZ

You can have a look to the JSXZ repository [here](https://github.com/kbrw/babel-preset-jsxz). 

Once we installed everything to transpile **JSXZ**, we can write our first 
**React** with a **JSXZ** page based on a **Webflow** template.  
As in the previous chapter, all our templates are inside a directory.  
We indicated this directory to **JSXZ** inside the Webpack configuration:  

``` javascript
presets: [['jsxz',{dir: "webflow"}]]
```

Let's write an example **React** that read JSON variable set locally in our 
JS script.  

Define an array that will be map over inside our `Page.render` function created before.  
``` javascript
var orders = [
  {remoteid: "000000189", custom: {customer: {full_name: "TOTO & CIE"}, billing_address: "Some where in the world"}, items: 2}, 
  {remoteid: "000000190", custom: {customer: {full_name: "Looney Toons"}, billing_address: "The Warner Bros Company"}, items: 3}, 
  {remoteid: "000000191", custom: {customer: {full_name: "Asterix & Obelix"}, billing_address: "Armorique"}, items: 29}, 
  {remoteid: "000000192", custom: {customer: {full_name: "Lucky Luke"}, billing_address: "A Cowboy doesn't have an address. Sorry"}, items: 0}, 
]

//To render this JSON in the table, we will have to map the list on a **`JSXZ`** render. 

{
  orders.map( order => (<JSXZ in="orders" sel=".table-line">
  <Z sel="...">{order.remoteid}</Z>
  ...
  </JSXZ>))
 }
```
_Don't forget that inside a `<JSXZ>` there must only be `<Z>` !_

## Step 4 - Modal and loaders

In your project you're gonna have times when you will do an heavy operation, and others where you will want to ask or show some specific information to your user.  
For that, we will use Loaders and Modals :)  
  
### Modal

A modal is a window inside your browser window.  
  
We're gonna design one into Webflow.  
  - Create a new page. Always create your modals inside their own page, it will be better later to include them into your project using **JSXZ**
  - Create a new div, it will be the container of our modal. We will name it `modal-wrapper`.
    - Assign it a `100%` Width and `100VH` Height.
    - Change it's background color so that it's a little bit grey.
    - Set its position to absolute, top left.
    - Set the z-index to 1000
  - Add a new div inside your `modal-wrapper`, we will call it `modal-content`
    - It will be our modal "window"
    - Put it at the center of your page, change the width and height
    - Make its position `fixed`, so that it will stay in the center even if your user is scrolling
    - Change the color of the background. Make it white for example.
    - Now inside it you can add some components like text, forms, media, etc.
  
You should obtain something like this:  
![modal_example](./img/modal_example.png)
  
And here we have our first modal ! Great isn't it ? :)  
  
But we're still missing something, we need to find a way to hide it.  
  
In Webflow, create a new CSS class called `hidden`.  
This class is pretty simple, just click on the **"hides elements"** in the display section.  
Test it by adding it to your `modal-wrapper` div. It should hide your modal **and** the grey background.   
  
_**Tip:** You class must be the only one on your component when you edit it. The simplest way is to create an **empty div**, create your CSS class, and then delete this div._
  
![hidden_class](./img/hidden_class.png)

### Loader

A loader is essentially the same thing as a modal, the difference is that it contains a GIF or an animated image.  
  
Follow the same principles of creation that we have with a modal:
  - Create a new page
  - Create our container div, this time name it `loader-wrapper`
    - Apply the same properties as we did before for the `modal-wrapper`
  - Create a new div called `loader-content`
    - Add an image inside it
    - You can use the website https://loading.io to create your own custom loader
  
And that's it ! If you want to hide it, add the `hidden` CSS class to your `wrapper` div et voilà ! :)
  
---
## Question time !

* What use a Loader or a Modal ?
* Why do we use **CSS** classes ?
* Qu'est-ce que Webflow ?

---
[Prev Chapter](chap3.html) **Chapter 4** [Next Chapter](chap5.html)
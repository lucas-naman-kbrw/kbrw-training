# Chapter 3: The Four Horsemen of the Apocalypse: React, Webpack, Babel and JSXZ

This chapter will introduce you to React and the tool chain that goes with it.  

## Step 0 - The White Rider: React 

  ### The Righteous Vanilla JS

Alongside HTML and CSS, [**Javascript**](https://en.wikipedia.org/wiki/JavaScript) is one of the core technologies of the World Wide Web.  
It enable interactive web pages and is an essential part of web applications. The vast majority of websites use it, and major web browsers have a dedicated JavaScript engine to execute it.  

---  
**Exercice:**  

We will explore its possibilities with a little example.  
Create a `web` subdirectory inside your **mix** project, we will work from here.  
  
First, let's create a really simple **HTML** file called `index.html`  
  - Create a big header with the text "Hello world" in it
  - Add a link to the website `kbrw.fr` with the text "KBRW Website"
  
Open it with your favorite web browser and you should obtain something like this:
![container](./img/the_righteous.png)
  
Now let's add some Javascript in it.  
  - Add a button with the text `Click me`
  - When you will click on this button, the page should display an alert with the content `Hello world !`
  - Your Javascript code **must** be inside a file named `script.js`
  - The alert code **must** be inside a Javascript function
  
And here it is ! You have a great web page, with some JS code executed inside it ! Bravo !

---

  ### React, the Infectuous JS Library

To help us create wonderful User Interface, we`re gonna use a library named **React**.  
_Go and read more about it [here](https://reactjs.org/)_
  
---
**Exercice:**  

We're gonna use **React** to manipulate the DOM of our web page.
 - Let's import the library inside our index.html
   - Add the following code `<script crossorigin src="https://unpkg.com/react@16/umd/react.production.min.js"></script>`
   - Do the same for `https://unpkg.com/react-dom@16/umd/react-dom.production.min.js`
   - This will import the script `reac.production.min.js` from the `unpkg.com` website
 - Now, in our `script.js` file, change the function that used to create an alert so that instead it will create a new `div` with the content `Hey I was created from React!`
 - You **must** use the function `React.createElement` 
 - Create an empty `div` with the `id=root`, you will render your element inside it using `ReactDOM`

_Play a little bit with it !_

---

  ### As Empire prosperity, JSX

_According to Edward Bishop Elliott's interpretation, that the Four Horsemen represent a prophecy of the subsequent history of the Roman Empire, the white color of this horse signifies triumph, prosperity and health in the political Roman body_

So, pretty cool han ? :) Ready to create Web App with 10000 calls to `React.createElement` ? :)  
    
Don't worry, **React** thought about you ! [JSX](https://reactjs.org/docs/introducing-jsx.html) is here to save the day.  
  
It is a **syntax extension** to JavaScript.  
It allows you to write code like `<div><h1>Hello</h1></div>` **INSIDE you JS script**.

Let's go, write some **JSX** inside your `script.js` file and see what happened !  

Perfect right ? No ? Got this `SyntaxError: expected expression, got '<'` ? :/  
It's because **JSX is a syntax extension**, and not actual JS.  
  
Javascript does not natively support JSX syntax. We're gonna have to use some new tools to support it.

  ### Let's get ready for War

  #### NodeJS and NPM

To **transform** our Javascript so that it can support JSX, we're gonna use tools like [Webpack](https://webpack.js.org/) by the intermediary of [NPM](https://www.npmjs.com/) and [NodeJS](https://nodejs.org/en/).  

Install NodeJS, following the way recommended for your Operating System.  

Now verify that everything went well and try:  
```sh
    $> npm  
    $> node
```
If this commands are working, that's it your done installing NodeJS and NPM !

  #### React

We will create a **React** project, using `npm`, and place it inside our **mix** project, in the folder `web`  
  ```sh
    $> npm init react-app web/  
    $> ls  
    node_modules  package.json  package-lock.json  public  README.md  src
  ```

We need to modify the architecture of our project compared to a common **React** application.  
You can remove the following directories and files:
  * `public/` -> we don't need **HTML** examples
  * `src/` -> we don't need source example
  * `.gitignore` -> we are already in a git
  * `.git/` -> idem
  * `README.md` -> no need of it

    #### Dependencies

All the dependencies of your `npm` project are written inside the [`package.json` file](https://docs.npmjs.com/creating-a-package-json-file).  
  
When you install a dependencies, it will write it in this file which is the equivalent of the file `mix.exs` in a **mix** project. It will save all the dependencies your project needs to be executed. And if you want to reinstall them, just type:  

    npm install 

The downloaded dependencies are placed in the folder **`node_modules`**. To install a new dependency of your project, you have to type 

    npm install <dep_name>

which will place it in the `dependencies` fields of your `package.json`.  
You can also sometimes want to install `devDependencies` which are different from the normal ones and not installed in your final project. This solution can be useful for transpilling lib. You can find a more complete answer [here](https://stackoverflow.com/questions/18875674/whats-the-difference-between-dependencies-devdependencies-and-peerdependencies). 
This dependencies installation method can be archieved by typing  

    npm install <dep_name> --save-dev
  
Let's open our `package.json` which should looks like: 
``` javascript
{
  "name": "web",
  "version": "0.1.0",
  "private": true,                                                              
  "dependencies": {...}, 
  "devDependencies": {...},
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": "react-app"
  },
  "browserslist": [...]
}
```

In this JSON you can delete the following fields:  
  - private
  - eslintConfig
  - browserslist
  - script
  
We are using **React v15.X**, check that your dependencies are correct !  
```js
{
  "name": "web",
  "version": "0.1.0",
  "dependencies": {
    "react": "^15.6.2",
    "react-dom": "^15.6.2"
  }
}
```

## Step 1 - The Read Horse: Webpack

[Webpack](https://webpack.js.org/concepts) is a resource manager.  
It will help us process our resources (`.js`, `.png`, `.html`, `.css`) and bundle them into a static application.  
It also provides a simple way to create plugins that will transform and handle this various resources.  
  
**READ the documentation at https://webpack.js.org/concepts**
  
  ### Installation

You can install `webpack` as a dependency in your NPM project.  
```sh
  $> npm install webpack@^3.0.0
```
To launch webpack, use this command inside your `web` folder:
```sh
  $> node node_modules/webpack/bin/webpack.js
```
  
You can see that webpack is looking for a configuration file, named `webpack.config.js`.    
This file will give to webpack every bit of information it needs to bundle your web application.  
Let's create this file and fill it.  

```js
module.exports = {
    entry: './script.js',
    output: { filename: 'bundle.js' },
    plugins: [],
    module: {},
  }
```
  - `entry` is the entry point of our web application. Webpack will parse this file and start its dependency graph based on its content.
  - `output` tells webpack where to emit the bundles it creates and how to name these files. It will wrap together all the `js` inside it.  

  
Let's execute Webpack with our `script.js` file, containing our `React` application (with `React.createElement`, no `JSX` for now).  
  
You should now see a file named `bundle.js` inside your directory. Open it and try to find your code inside it :)

  ### Javascript is dead, long live Javascript !

Until now we only used **Vanilla Javascript**.  
The function you defined must likely look like this:  
```js
  function test() {
    console.log("Hello!")
  }
```
And you maybe ended up at first creating one looking like this:  
```js
  var test = ()=>{
    console.log("Hello!")
  }
```
But it didn't work.  
**Why ?** This feature of the language is not yet supported by all browser. It is part of [**ECMAScript 2015 features**](https://babeljs.io/docs/en/learn/).  
  
  ### As Empire division

To be able to use the previous code, we will **transform** it into vanilla Javascript.  
We're gonna [**transpile**](https://en.wikipedia.org/wiki/Source-to-source_compiler) our code.  
  
To do so, we will use a feature of webpack called **Loaders**.  
  
Taken from the [documentation](https://webpack.js.org/concepts#loaders) of Webpack (**go read it**):  
```
Out of the box, webpack only understands JavaScript and JSON files.  
Loaders allow webpack to process other types of files and convert them into valid  
modules that can be consumed by your application and added to the dependency graph.
```
  
The transpiler we will use is called [**Babel**](https://babeljs.io/).  
  
Let's install it into our project, as well as the **ECMAScript 2015** plugin.  
```sh
  $> npm install --save-dev babel-core@^6
  $> npm install --save-dev babel-loader@^7
  $> npm install --save-dev babel-preset-es2015@^6
```
  
Now that we have **Babel** and its plugin installed, we need to tell **Webpack** to use it on all our `.js` files.  
Here is our new `webpack.config.js`:
```js
module.exports = {
    entry: './script.js',
    output: { filename: 'bundle.js' },
    plugins: [],
    module: {
      loaders: [
        {
          test: /.js?$/,
          loader: 'babel-loader',
          exclude: /node_modules/,
          query: {
            presets: ['es2015']
          }
        }
      ]
    },
  }
```
  
Now, replace the declaration of your `function` inside your `script.js` file to use the modern declaration `() => {}`.  
Bundle your application using **Webpack** and take a look in the `bundle.js` file to see the transpiled code.  
```js
//This
  var test = () => {}

//Became this
  test = function test() {};
```
  
**Here, `'es2015'` is a plugin of Babel.**  

  ### JSX

Install the `react` babel's plugin and the `jsx` dependency.
```sh
  $> npm install --save-dev babel-preset-react@^6
  $> npm install --save-dev jsx
```
  
We also need to tell Webpack to use it: add the `'react'` preset next to the `'es2015'` one.  
  
Remove all occurences of the `React.createElement` function, and use [JSX](https://reactjs.org/docs/introducing-jsx.html) instead.  
  
Bundle it using Webpack, Babel will transpile your JSX code into vanilla js.  
  
**We're all set ! You should be able to use JSX core inside your web application. Go and take a look at your `bundle.js` file**  

  ### Debugging

To help debugging, you can use the [dev-tool](https://webpack.js.org/configuration/devtool/) option of Webpack.

## Step 2 - The Black Horse: Babel

Babel is a `source-to-source compiler`.  
It parses the source code of your project into an [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree), allows plugins to transform it, and generates new code based on the modified version of this [AST](https://en.wikipedia.org/wiki/Abstract_syntax_tree).  
  
![transpilation](./img/transpilation.png)
_Source: [medium](https://medium.com/@marianococirio/build-your-own-babel-plugin-from-scratch-8db0162f983a)_
  

  ### My Custom Babel plugin

To really understand how **Babel** works, we're gonna create a little plugin.  
```js
//The aim is to transpile a source code like this:
  <Declaration var="test" value={42}/>
  <Declaration var="kbrw" value="the best"/>

//Into
  var test = 42
  var kbrw = "the best"
```
  
**Read the [Babel Plugin Handbook](https://github.com/jamiebuilds/babel-handbook/blob/master/translations/en/plugin-handbook.md)**  
  
  #### Our Babel project

Create a new NPM project.  
  
We will need some few dependencies, JSX is one of them.  
Indeed, `<Declaration/>` is not regular JS, this is JSX and we must tell Babel that our plugin is gonna use it.  
  
Our `package.json` should contains something like this:  
```js
  "dependencies": {
    "babel-types": "^6.20.0",
    "babel-plugin-syntax-jsx": "^6.18.0"
  },
  "devDependencies": {
    "babel-core": "^6.20.0"
  }
```
  
Now, having read the [Babel Plugin Handbook](https://github.com/jamiebuilds/babel-handbook/blob/master/translations/en/plugin-handbook.md), you should be able to create a plugin that replace a given [JSXElement](https://babeljs.io/docs/en/babel-types#jsxelement) by what you need.  
_The documentation of babel-types might help you [here](https://babeljs.io/docs/en/babel-types)_  
  
**Useful tips:**
  - Go and take a look at our homemade preset, called [**JSXZ**](https://github.com/kbrw/babel-plugin-transform-jsxz/)
  - Look into your `bundle.js` file to see your transpiled code
  - You can easily see the AST of Babel given some JS code on this website: https://astexplorer.net/, **USE IT**.
  - What is the difference in the AST between this two declarations
```js
  <Declaration var="test" value="42"/>
  <Declaration var="test" value={42}/>
```
  
I should be able to call you plugin in webpack like this:  
```js
    module: {
      loaders: [
        {
          test: /.js?$/,
          loader: 'babel-loader',
          exclude: /node_modules/,
          query: {
            presets: ['es2015', 'react'],
            plugins: ['my-babel-plugin']
          }
        }
      ]
    },
```

## Step 3 - The Pale Horse: JSXZ

You should now have a better understanding on how the presets `es2015` and `react` works.  
  
All our web applications use **React**, as well as a homemade Babel plugin named **JSXZ**.  
_**Go and take a look at JSXZ here: https://github.com/kbrw/babel-preset-jsxz**_  
  
**JSXZ** is using what we call a **CSS selector**. This means that when rendering our web page, we will be able to target specific **CSS classes** to alter it and inject custom values.  
This is gonna help us **separate the design** of our pages from their **integration**.  

  ### Dependencies

Let's add some new dependencies to our web project:
```sh
  $> npm install --save-dev babel-preset-jsxz
  $> npm install --save-dev babel-preset-stage-0@^6
  $> npm install --save-dev create-react-class@^15
```
  
_I will let you take a look at the other two dependencies_  
  
  ### Sample project

We now add `jsxz` in Webpack.  
It takes as parameter a directory inside which it's gonna look for the template files.
Here it will be `webflow`.  
```js
            presets: ['es2015', 'react',
            [
              'jsxz',
              {
                  dir: 'webflow'
              }
          ]],
```

Let's create a file `template.html` inside this directory.
```html
<div class="container">
    <p class="item">This is an item</p>
    <p class="price">This is a price</p>
</div>
```
  
Now, let's render this page inside our `script.js`, replacing the content of the two `<p>`.  
```js
  var createReactClass = require('create-react-class')

  var Page = createReactClass({
    render(){
      return <JSXZ in="template" sel=".container">
        <Z sel=".item">Burgers</Z>,
        <Z sel=".price">50</Z>
      </JSXZ>
    }
  })

  ReactDOM.render(
    <Page/>,
    document.getElementById('root')
  )
```
  
Run Webpack and open your index.html file.  
You should see that the content of both `p` have been replaced by `Burgers` and `50`.  
  
**NOTE: Always use the `.` class selector inside KBRW projects.**  
_If you have some js errors, remember that the script file you need to use is now bundle.js_

---
## Question time !

* Define *transpiling*
* Why use **Babel** ?
* Why use **Webpack** ?
* Can we use Babel **without** Webpack ?

---
[Prev chapter](chap2.html) **Chapter 3** [Next chapter](chap4.html) 
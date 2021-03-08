# babel-preset-jsxz

> Babel preset for JSXZ transform

see [https://github.com/awetzel/babel-plugin-transform-jsxz](https://github.com/awetzel/babel-plugin-transform-jsxz)

For more explanation about the JSXZ transformation : generate your
react component from html at compile time.

## Install

```sh
npm install --save babel-preset-jsxz
```

## Usage

```json
{
  "presets": ["jsxz"]
}
```

You can specify the HTML template relative dir with the "dir" option.

```json
{
  "presets": [["jsxz",{dir: "/path/to/my/templates"}]]
}
```


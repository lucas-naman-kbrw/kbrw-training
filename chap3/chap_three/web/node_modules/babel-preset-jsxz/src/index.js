module.exports = function(context, opts) {
  return {
    plugins: [
      [require("babel-plugin-transform-jsxz").default,{templatesDir: opts.dir}]
    ]
  }
}

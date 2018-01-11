var path = require("path");
var fs = require("fs");

module.exports = {
  entry: "./index.js",
  output: {
    library: "index",
    libraryTarget: "commonjs2",
    filename: "./dist/index.js"
  },
  target: "node",
  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: JSON.parse(
          fs.readFileSync(path.join(__dirname, ".babelrc"), {encoding: "utf8"})
        )
      },
      {
        test: /\.json$/,
        loader: 'json-loader'
      }
    ]
  }
};
# FS Read Interceptor
[![Build Status](https://travis-ci.org/CodeLenny/fs-intercept.svg?branch=master)](https://travis-ci.org/CodeLenny/fs-intercept)
[![npm](https://img.shields.io/npm/v/fs-intercept.svg)]()

FS Read Interceptor automatically transforms files as they are read into your [Node.js][] script or application.

Designed for bundling tools like [polymer-bundler][] and [Browserify][] that automatically bundle dependencies into a
single file, this library adds precompilation steps when files are read.

The same rules can also be applied to files served by [serve-static][], replacing compilation middleware.

:warning: Read Interceptor is only intended to be used during development and compilation.  See the
[Limitations](#limitations) for more information.

## Basic Usage

Install `fs-intercept` via [NPM][]

```sh
npm install --save-dev fs-intercept
```

Define or import `InterceptRule`s.

```js
"use strict";
const InterceptRule = require("fs-intercept/InterceptRule");
class CoffeeScriptIntercept extends InterceptRule {
  
  intercept(path) { return path.indexOf(".js") > -1; }
  
  readFile(path, options, callback) {
    require("fs").readFile(path.replace(".js", ".coffee"), "utf8", function(err, cs) {
      if(err) { return cb(err); }
      cb(null, require("coffee-script").compile(cs));
    });
  }
  
}
module.exports = CoffeeScriptIntercept;
```

Use `InterceptRule`s, and start intercepting files.

```js
var FSReadInterceptor = require("fs-intercept");
var interceptor = new FSReadInterceptor();
interceptor.use(new CoffeeScriptIntercept());
interceptor.intercept();
```

Now `fs.readFile("src.js");` will compile `src.coffee` if `src.js` isn't found. and return the corresponding JavaScript.

### Implemented Methods

- `fs.readFile`, `fs.readFileSync`
- `fs.stat`, `fs.lstat`
- `fs.createReadStream`

### Tested Environments

- ![`express.static()` Tested][express-static-badge] [serve-static][]
- ![`polymer-bundler` Tested][polymer-bundler-badge] [polymer-bundler][]
- ![`browserify` Tested][browserify-badge] [Browserify][]

Please suggest additional environments to test, so they can be added to the automated testing suite.

[express-static-badge]: https://img.shields.io/badge/express.static()-tested-brightgreen.svg?style=flat-square
[polymer-bundler-badge]: https://img.shields.io/badge/polymer--bundler-tested-brightgreen.svg?style=flat-square
[browserify-badge]: https://img.shields.io/badge/browserify-tested-brightgreen.svg?style=flat-square

## Limitations

### No Caching
:construction: This limitation will be removed in a future release.

Currently, no caching is applied to transformations made when files are read.  This would cause poor latency when
reading files multiple times.

### Partial Implementation
:no_entry_sign: This limitation is potentially removable, but is not planned to be removed.

Read Interceptor overrides several of the [fs][node-fs] methods, but by no means has an exhaustive implementation for
all of Node's file system methods.  This means that while `fs.readFile` might correctly transform files, `fs.watch`
would not handle the file transformation.

See the list of [implemented methods](#implemented-methods) for more information.

In addition, FS Read Interceptor only works for file reads that go through the JavaScript `fs` API.  Calls through C
functions and other executable programs (`cat`, `md5`, Python, etc.) would not have file transformations applied.

### Synchronous and Stream Method Wrapping
:information_source: This limitation can be avoided if users spend extra effort when writing Interceptors.

To allow quicker usage, Interceptors only require the asynchronous methods to be implemented.  Synchronous and
file-stream versions of methods are created by default, which wrap the asynchronous method.

Environments made for Streams or expecting synchronous methods might experience performance issues if the asynchronous
wrapping is used.  To prevent this, users can implement stream and synchronous versions of their Interceptor logic.

### Stream Implementation
:construction: This limitation *may* be removed in a future release.

The current implementation of `createReadStream` doesn't take advantage of read streams to pipe data, as data can come
from multiple sources - direct from the file system, or transformed from another file.


[Node.js]: https://nodejs.org/
[NPM]: https://www.npmjs.com/
[polymer-bundler]: https://github.com/Polymer/polymer-bundler
[Browserify]: http://browserify.org/
[serve-static]: https://github.com/expressjs/serve-static
[node-fs]: https://nodejs.org/api/fs.html

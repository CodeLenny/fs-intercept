## Unreleased

## 0.1.0 - 2017-02-21

First version.  Added basic set of read methods, which work for `express.static`, polymer-bundler, and Browserify.

### Added

- Basic FS read methods: `readFile`, `readFileSync`, `stat`, `lstat`, `createReadStream`
- Integration tests
  - `express.static`
  - polymer-bundler
  - Browserify
- FSReadInterceptor and InterceptRule API

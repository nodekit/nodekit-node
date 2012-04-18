##nodekit-node
[![Build Status](https://secure.travis-ci.org/nodekit/nodekit-node.png?branch=master)](http://travis-ci.org/nodekit/nodekit-node)
### Usage
```coffeescript
inkit = require 'inkit'

ink = new inkit { secret: 'xxxx', token: 'xxxx' }
ink.haml view, {}, (code) ->
  console.log code
```
### Specs
Tests use cucumber.js

`cucumber.js`

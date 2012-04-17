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

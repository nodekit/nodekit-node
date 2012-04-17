{Inkit} = require '../../../source/inkit'
request = require 'request'
querystring = require 'querystring'

test = (type,code) ->
  !!switch type
    when 'haml'
      code.match /%[A-Za-z0-9]*/
    when 'html'
      code.match /<[A-Za-z0-9]*>/
    when 'json'
      code.match /^\{/
    when 'jade'
      code.match /\((.*)='(.*)'\)/
    when 'coffeekup'
      code.match /,\s->/
    else
      false
steps = ->
  @Given /^I have (.*) secret and (.*) token$/, (secret, token, callback)->
    @ink = new Inkit { secret: secret, token: token}
    @ink.endpoint = 'api.inkit.dev'
    @code = []
    callback()

  @When /^I render the (.*) view in:/, (view,table,callback) ->
    j = 0 
    table.raw().forEach (a,i) =>
      method = a[0].toLowerCase()
      code = @ink[method] view, {}, (code) =>
        @code[method] = code
        j++
        if j is table.raw().length
          callback()

  @When /^I try to get (.*) view as (.*)$/, (view,type,callback) ->
    @ink[type.toLowerCase()] view, {}, (code) =>
      @response = code
      callback()

  @When /^I query for documents$/, (callback) ->
    @ink.documents (docs) =>
      @docs = docs
      callback()

  @Then /^I shoud get an array of documents$/, (callback) ->
    if typeof @docs is 'object'
      callback()
    else
      callback.fail()

  @When /^I try to get (.*) view when not modified$/, (view,callback) ->
    data = { timestamp: new Date().toISOString()}
    data.modified_since = new Date().toISOString()
    data.digest = @ink.digest(data)
    data.token = @ink.token
    req = request.get "http://#{@ink.endpoint}/document/#{view.toString()}.json?"+querystring.stringify(data), (err,res,body) =>
      @response = res.statusCode
      callback()
    req.end()


  @Then /^I shoud get a (\d+) response$/, (arg1,callback) ->
    if @response.toString() is arg1
      callback()
    else
      callback.fail()


  @Then /^I shoud get the code in:$/, (table,callback) ->
    table.raw().forEach (a,i) =>
      method = a[0].toLowerCase()
      callback.fail() unless test(method,@code[method].toString())
    callback()

module.exports = steps

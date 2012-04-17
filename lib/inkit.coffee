crypto = require 'crypto'
request = require 'request'
{Cache} = require './cache'
querystring = require 'querystring'
hogan = require 'hogan'

class Inkit
  constructor: (options) ->
    throw 'Please provide your secret key!' unless options['secret']
    @secret = options['secret'].toString()
    @token = options['token'].toString()
    @endpoint = 'api.inkit.dev'
    @cache = new Cache @secret
    ['haml','html','json','jade','coffeekup'].forEach (method) =>
      @[method] = (view, options = {}, callback = ->) ->
        @render view, method, options, callback
        
  documents: (callback) ->
    @request "documents", {}, (err, res, body) ->
      if res.statusCode is 200
        callback JSON.parse body
      else
        callback res.statusCode
  
  digest: (string) ->
    string = querystring.stringify string
    signer = crypto.createHmac('sha256', new Buffer(@secret, 'utf8'))
    signer.update(string.toString()).digest('hex')
    
  render: (view, type = 'html', options = {}, callback = ->) ->
    @pull view, type, (ret) ->
      if typeof ret is 'number'
        callback ret
        return
      ret.replace /\s*$/, ''
      template = hogan.compile ret
      callback template.render options.locals

  pull: (view, type = 'haml', callback = ->) ->
    v = view+"."+type
    data = {}
    data['modified_since'] = @cache.cached_at(v) if @cache.cached(v)
    @request "document/"+v, data, (err, res, body) =>
      if res.statusCode is 200
        @cache.set v, res.body
        callback res.body
      else if res.statusCode is 304
        callback @cache.get v
      else 
        callback res.statusCode 
    
  request: (path, data = {}, callback) ->
    data['timestamp'] = new Date().toISOString()
    data['digest'] = @digest(data)
    data['token'] = @token
    req = request.get "http://#{@endpoint}/#{path.toString()}?"+querystring.stringify(data), callback
    req.end()
  
exports.Inkit = Inkit

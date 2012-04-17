fs = require 'fs'
crypto = require 'crypto'
path = require 'path'

exports.Cache = class Cache
  constructor: (secret) ->
    @secret = secret
    @cache_dir = './.ink-cache'
    fs.mkdirSync @cache_dir unless path.existsSync @cache_dir
    
  set: (name,data) ->
    fs.writeFileSync @filename(name), data, 'utf-8'

  get: (name) ->
    fs.readFileSync @filename(name), 'utf-8'
  
  cached_at: (name) ->
    fs.statSync(@filename(name)).mtime.toISOString()
    
  cached: (name) ->
    path.existsSync @filename(name)
    
  filename: (name) ->
    a = path.extname name
    b = path.basename name, a 
    @cache_dir+"/."+@hexdigest(b)+a

  hexdigest: (string) ->
    signer = crypto.createHmac('sha256', new Buffer(@secret, 'utf8'))
    signer.update(string.toString()).digest('hex')
    

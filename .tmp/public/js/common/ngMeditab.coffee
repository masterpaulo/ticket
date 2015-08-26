ngMeditab = angular.module('ngMeditab', [ 'ngRoute' ])
ngMeditab.factory 'ApiObject', [
  "$http"
  "meditabApiUrl"
  "apiUtils"
  'hawk'
  'hawkCredentials'
  'hawkCredentialsDynamic'
  ($http, meditabApiUrl, apiUtils, hawk, hawkCredentials, hawkCredentialsDynamic)->
    ###
      REQUEST INITIALIZER - returns a configured request object
        query( QUERY )
        list()
        show(ID)
        create(OBJECT)
        update(ID,OBJECT)
        delete(ID)

      REQUEST EXTENDERS - adds more configuration to the request object
        populate(STRING)
        limit(INTEGER)
        page(INTEGER)
        skip(INTEGER)
        sort( STRING )

      REQUEST EXECUTION - executes the ajax request
        exec

    ###
    REQUEST = (url,method,data)->

      @.url = url
      @.method = method
      @.data = data
      @.params = []
      return      

    REQUEST.prototype.limit = (int)->
      @.params.push "limit="+int if int isnt undefined or int isnt null
      return this

    REQUEST.prototype.sort = (key)->
      @.params.push "sort="+key if key
      return this

    REQUEST.prototype.populate = (key)->
      @.params.push "populate="+key if key
      return this

    REQUEST.prototype.page = (int)->
      @.params.push "page="+int if int isnt undefined or int isnt null
      return this

    REQUEST.prototype.skip = (int)->
      @.params.push "skip="+int if int isnt undefined or int isnt null
      return this

    REQUEST.prototype.exec = (callback)->
      url = meditabApiUrl.api+(if meditabApiUrl.port isnt 80 then (":"+meditabApiUrl.port) else "" )+"/"+@.url
      url+= "?"+ @.params.join "&" if @.params.length

      credentials = hawkCredentialsDynamic.get()
      credentials = hawkCredentials if !credentials
      header = hawk.client.header(url, @method, credentials: credentials)
      ajax = null

      config =
        method: @.method
        url: url
        headers:
          'Authorization': header.field
      config.data = @.data if @.data

      ajax = $http config
      
      ajax
      .success (data)->
        callback null,(if data.rows then data.rows else data )
      .error (error)->
        console.error error if console.error
        callback error

    AO = (name)->
      @.name = name

    AO.prototype.get = (url)->
      req = new REQUEST url,"get"
      return req

    AO.prototype.post = (url,data)->
      req = new REQUEST url,"post"
      req.data = data if data
      return req

    AO.prototype.put = (url,data)->
      req = new REQUEST url,"put"
      req.data = data if data
      return req

    AO.prototype.del = (url)->
      req = new REQUEST url,"delete"
      return req


    AO.prototype.show = (id)->
      url = @.name+"/show/"+id
      return @.get url

    AO.prototype.list = ->
      url = @.name+"/list"
      return @.get url

    AO.prototype.find = (query)->
      url = @.name+"/search"
      req = @.get url
      req.params.push "q="+ apiUtils.serialize query
      return req

    AO.prototype.create = (data)->
      url = @.name+"/create"     
      return @.post url,data

    AO.prototype.update = (id,data)->
      url = @.name+"/update/"+id
      return @.put url,data

    AO.prototype.delete = (id)->
      url = @.name+"/remove/"+id
      return this.del url

    return AO

]
ngMeditab.service 'apiUtils',[
  ->
    # to serialize sequelize query format to json string readable by the api server
    @serialize = (obj) ->
      return encodeURIComponent(JSON.stringify obj)


    return
]
ngMeditab.factory 'hawkInterceptor', [
  'hawk'
  'hawkCredentials'
  'hawkCredentialsDynamic'
  'meditabApiUrl'
  (hawk, hawkCredentials, hawkCredentialsDynamic, meditabApiUrl) ->
    hawkInterceptor = undefined
    hawkInterceptor =
      request: (config) ->
        url = config.url
        config.headers['ajax'] = true if url and url.indexOf(meditabApiUrl.api) is -1
        config

    hawkInterceptor
]

ngMeditab.service "hawkCredentialsRenewer",[
  "$http"
  "hawkCredentialsDynamic"
  "$timeout"
  "meditabApiUrl"
  ($http,hawkCredentialsDynamic,$timeout, meditabApiUrl)->
    @renew = ->
      renewer = @
      $http.get meditabApiUrl.renewCredential
      .success (data)->
        if data.id
          hawkCredentialsDynamic.set data
          renewer.timer data.ms
        else
          ###
            user might not be logged in
            return to homepage
          ###
          #document.location = '/'

    @timer = (ms)->
      renewer = @
      $timeout ->
        renewer.renew()
      , ms

    @start = ->
      renewer = @
      $http.get meditabApiUrl.expiration
      .success (data)->
        if data.id
          ###
            means data expired already
          ###
          credential =
            id: data.id
            key: data.key

          hawkCredentialsDynamic.set credential
          renewer.timer data.ms
        else
          renewer.timer data.ms

    return
]
ngMeditab.service "hawkCredentialsDynamic",[
  ->
    credentials =
      id : false
      key : false
      algorithm: 'sha256'

    @set = (data)->
      credentials.id = data.id
      credentials.key = data.key
    @get = ->
      c = credentials
      c = false if !c.id or !c.key
      return c
    return
]
ngMeditab.provider 'hawkCredentials', [->
    credentials = 
      algorithm: 'sha256'
      key: 'none'
      id: false

    @set = (c) ->
      credentials.id = c.id
      credentials.key = c.key
      return

    @$get = ->
      credentials

    return
]
ngMeditab.provider 'meditabApiUrl', [ ->
  config =
    api: "api.meditab.com"
    port: 80
    getCredential: "/apicredential/get"
    renewCredential: "/apicredential/renew"
    expiration: "/apicredential/expiration"

  @set = (newConfig)->
    for key of newConfig
      config[key] = newConfig[key]

  @$get = ->
    return config

  return
]
getCookie = (cname) ->
  name = cname + '='
  ca = document.cookie.split(';')
  i = 0
  while i < ca.length
    c = ca[i]
    while c.charAt(0) == ' '
      c = c.substring(1)
    if c.indexOf(name) == 0
      return c.substring(name.length, c.length)
    i++
  ''
ngMeditab.config([
  '$routeProvider'
  '$locationProvider'
  '$httpProvider'
  '$sceDelegateProvider'
  'meditabApiUrlProvider'
  'hawkCredentialsProvider'
  ($routeProvider, $locationProvider, $httpProvider, $sceDelegateProvider, meditabApiUrlProvider, hawkCredentialsProvider) ->

    $httpProvider.interceptors.push 'hawkInterceptor'
    $httpProvider.defaults.transformRequest.push (data, headersGetter) ->
      d = undefined
      utf8_data = undefined
      utf8_data = data
      if !angular.isUndefined(data)
        d = angular.fromJson(data)
        d['utf8'] = '&#9731;'
        utf8_data = angular.toJson(d)
      utf8_data

    # enable CORS and whitelist the api URL
    $sceDelegateProvider.resourceUrlWhitelist [
      'self'
      'http://' + meditabApiUrlProvider.api + '/**'
    ]

    # get temporary and expiring api credential
    credentials = 
      id: decodeURIComponent getCookie('tempId')
      key: getCookie('tempKey')

    hawkCredentialsProvider.set credentials if credentials.id and credentials.key
    return
])
ngMeditab.run [
  '$http'
  'meditabApiUrl'
  'hawkCredentialsRenewer'
  ($http, meditabApiUrl, hawkCredentialsRenewer) ->

    ###
    if credential is not set in the cookie 
    request credential via ajax
    ###
    credentials = 
      id: decodeURIComponent getCookie('tempId')
      key: getCookie('tempKey')

    if !credentials.id or !credentials.key
      $http.get( meditabApiUrl.getCredential )
      .success (data)->
        hawkCredentialsDynamic.set data if data.id and data.key

    hawkCredentialsRenewer.start()
    return
]

ngMeditab.service 'hawk', [ ->
  hawk = this
  @internals = {}
  @client =
    header: (uri, method, options) ->
      artifacts = undefined
      hasExt = undefined
      header = undefined
      mac = undefined
      result = undefined
      timestamp = undefined
      result =
        field: ''
        artifacts: {}
      if !uri or typeof uri != 'string' and typeof uri != 'object' or !method or typeof method != 'string' or !options or typeof options != 'object'
        result.err = 'Invalid argument type'
        return result
      timestamp = options.timestamp or hawk.utils.now(options.localtimeOffsetMsec)
      credentials = options.credentials
      if !credentials or !credentials.id or !credentials.key or !credentials.algorithm
        result.err = 'Invalid credentials object'
        return result
      if hawk.crypto.algorithms.indexOf(credentials.algorithm) == -1
        result.err = 'Unknown algorithm'
        return result
      if typeof uri == 'string'
        uri = hawk.utils.parseUri(uri)
      artifacts =
        ts: timestamp
        nonce: options.nonce or hawk.utils.randomString(6)
        method: method
        resource: uri.relative
        host: uri.hostname
        port: uri.port
        hash: options.hash
        ext: options.ext
        app: options.app
        dlg: options.dlg
      result.artifacts = artifacts
      if !artifacts.hash and (options.payload or options.payload == '')
        artifacts.hash = hawk.crypto.calculatePayloadHash(options.payload, credentials.algorithm, options.contentType)
      mac = hawk.crypto.calculateMac('header', credentials, artifacts)
      hasExt = artifacts.ext != null and artifacts.ext != undefined and artifacts.ext != ''
      header = 'Hawk id="' + credentials.id + '", ts="' + artifacts.ts + '", nonce="' + artifacts.nonce + (if artifacts.hash then '", hash="' + artifacts.hash else '') + (if hasExt then '", ext="' + hawk.utils.escapeHeaderAttribute(artifacts.ext) else '') + '", mac="' + mac + '"'
      if artifacts.app
        header += ', app="' + artifacts.app + (if artifacts.dlg then '", dlg="' + artifacts.dlg else '') + '"'
      result.field = header
      result
    bewit: (uri, options) ->
      bewit = undefined
      exp = undefined
      mac = undefined
      now = undefined
      if !uri or typeof uri != 'string' or !options or typeof options != 'object' or !options.ttlSec
        return ''
      options.ext = if options.ext == null or options.ext == undefined then '' else options.ext
      now = hawk.utils.now(options.localtimeOffsetMsec)
      credentials = options.credentials
      if !credentials or !credentials.id or !credentials.key or !credentials.algorithm
        return ''
      if hawk.crypto.algorithms.indexOf(credentials.algorithm) == -1
        return ''
      uri = hawk.utils.parseUri(uri)
      exp = now + options.ttlSec
      mac = hawk.crypto.calculateMac('bewit', credentials,
        ts: exp
        nonce: ''
        method: 'GET'
        resource: uri.relative
        host: uri.hostname
        port: uri.port
        ext: options.ext)
      bewit = credentials.id + '\\' + exp + '\\' + mac + '\\' + options.ext
      hawk.utils.base64urlEncode bewit
    authenticate: (request, credentials, artifacts, options) ->
      attributes = undefined
      calculatedHash = undefined
      getHeader = undefined
      mac = undefined
      modArtifacts = undefined
      serverAuthorization = undefined
      tsm = undefined
      wwwAuthenticate = undefined
      options = options or {}

      getHeader = (name) ->
        `var attributes`
        attributes = undefined
        if request.getResponseHeader
          request.getResponseHeader name
        else
          request.getHeader name

      wwwAuthenticate = getHeader('www-authenticate')
      if wwwAuthenticate
        attributes = hawk.utils.parseAuthorizationHeader(wwwAuthenticate, [
          'ts'
          'tsm'
          'error'
        ])
        if !attributes
          return false
        if attributes.ts
          tsm = hawk.crypto.calculateTsMac(attributes.ts, credentials)
          if tsm != attributes.tsm
            return false
          hawk.utils.setNtpOffset attributes.ts - Math.floor((new Date).getTime() / 1000)
      serverAuthorization = getHeader('server-authorization')
      if !serverAuthorization and !options.required
        return true
      attributes = hawk.utils.parseAuthorizationHeader(serverAuthorization, [
        'mac'
        'ext'
        'hash'
      ])
      if !attributes
        return false
      modArtifacts =
        ts: artifacts.ts
        nonce: artifacts.nonce
        method: artifacts.method
        resource: artifacts.resource
        host: artifacts.host
        port: artifacts.port
        hash: attributes.hash
        ext: attributes.ext
        app: artifacts.app
        dlg: artifacts.dlg
      mac = hawk.crypto.calculateMac('response', credentials, modArtifacts)
      if mac != attributes.mac
        return false
      if !options.payload and options.payload != ''
        return true
      if !attributes.hash
        return false
      calculatedHash = hawk.crypto.calculatePayloadHash(options.payload, credentials.algorithm, getHeader('content-type'))
      calculatedHash == attributes.hash
    message: (host, port, message, options) ->
      artifacts = undefined
      result = undefined
      timestamp = undefined
      if !host or typeof host != 'string' or !port or typeof port != 'number' or message == null or message == undefined or typeof message != 'string' or !options or typeof options != 'object'
        return null
      timestamp = options.timestamp or hawk.utils.now(options.localtimeOffsetMsec)
      credentials = options.credentials
      if !credentials or !credentials.id or !credentials.key or !credentials.algorithm
        return null
      if hawk.crypto.algorithms.indexOf(credentials.algorithm) == -1
        return null
      artifacts =
        ts: timestamp
        nonce: options.nonce or hawk.utils.randomString(6)
        host: host
        port: port
        hash: hawk.crypto.calculatePayloadHash(message, credentials.algorithm)
      result =
        id: credentials.id
        ts: artifacts.ts
        nonce: artifacts.nonce
        hash: artifacts.hash
        mac: hawk.crypto.calculateMac('message', credentials, artifacts)
      result
    authenticateTimestamp: (message, credentials, updateClock) ->
      tsm = undefined
      tsm = hawk.crypto.calculateTsMac(message.ts, credentials)
      if tsm != message.tsm
        return false
      if updateClock != false
        hawk.utils.setNtpOffset message.ts - Math.floor((new Date).getTime() / 1000)
      true
  @crypto =
    headerVersion: '1'
    algorithms: [
      'sha1'
      'sha256'
    ]
    calculateMac: (type, credentials, options) ->
      hmac = undefined
      normalized = undefined
      normalized = hawk.crypto.generateNormalizedString(type, options)
      hmac = CryptoJS['Hmac' + credentials.algorithm.toUpperCase()](normalized, credentials.key)
      hmac.toString CryptoJS.enc.Base64
    generateNormalizedString: (type, options) ->
      normalized = undefined
      normalized = 'hawk.' + hawk.crypto.headerVersion + '.' + type + '\n' + options.ts + '\n' + options.nonce + '\n' + (options.method or '').toUpperCase() + '\n' + (options.resource or '') + '\n' + options.host.toLowerCase() + '\n' + options.port + '\n' + (options.hash or '') + '\n'
      if options.ext
        normalized += options.ext.replace('\\', '\\\\').replace('\n', '\\n')
      normalized += '\n'
      if options.app
        normalized += options.app + '\n' + (options.dlg or '') + '\n'
      normalized
    calculatePayloadHash: (payload, algorithm, contentType) ->
      hash = undefined
      hash = CryptoJS.algo[algorithm.toUpperCase()].create()
      hash.update 'hawk.' + hawk.crypto.headerVersion + '.payload\n'
      hash.update hawk.utils.parseContentType(contentType) + '\n'
      hash.update payload
      hash.update '\n'
      hash.finalize().toString CryptoJS.enc.Base64
    calculateTsMac: (ts, credentials) ->
      hash = undefined
      hash = CryptoJS['Hmac' + credentials.algorithm.toUpperCase()]('hawk.' + hawk.crypto.headerVersion + '.ts\n' + ts + '\n', credentials.key)
      hash.toString CryptoJS.enc.Base64

  @internals.LocalStorage = ->
    @_cache = {}
    @length = 0

    @getItem = (key) ->
      if @_cache.hasOwnProperty(key)
        String @_cache[key]
      else
        null

    @setItem = (key, value) ->
      @_cache[key] = String(value)
      @length = Object.keys(@_cache).length
      return

    @removeItem = (key) ->
      delete @_cache[key]
      @length = Object.keys(@_cache).length
      return

    @clear = ->
      @_cache = {}
      @length = 0
      return

    @key = (i) ->
      Object.keys(@_cache)[i or 0]

    return

  @utils =
    storage: new (hawk.internals.LocalStorage)
    setStorage: (storage) ->
      ntpOffset = undefined
      ntpOffset = hawk.utils.storage.getItem('hawk_ntp_offset')
      hawk.utils.storage = storage
      if ntpOffset
        hawk.utils.setNtpOffset ntpOffset
      return
    setNtpOffset: (offset) ->
      err = undefined
      try
        hawk.utils.storage.setItem 'hawk_ntp_offset', offset
      catch _error
        err = _error
        console.error '[hawk] could not write to storage.'
        console.error err
      return
    getNtpOffset: ->
      offset = undefined
      offset = hawk.utils.storage.getItem('hawk_ntp_offset')
      if !offset
        return 0
      parseInt offset, 10
    now: (localtimeOffsetMsec) ->
      Math.floor(((new Date).getTime() + (localtimeOffsetMsec or 0)) / 1000) + hawk.utils.getNtpOffset()
    escapeHeaderAttribute: (attribute) ->
      attribute.replace(/\\/g, '\\\\').replace /\"/g, '"'
    parseContentType: (header) ->
      if !header
        return ''
      header.split(';')[0].replace(/^\s+|\s+$/g, '').toLowerCase()
    parseAuthorizationHeader: (header, keys) ->
      attributes = undefined
      attributesString = undefined
      headerParts = undefined
      scheme = undefined
      verify = undefined
      if !header
        return null
      headerParts = header.match(/^(\w+)(?:\s+(.*))?$/)
      if !headerParts
        return null
      scheme = headerParts[1]
      if scheme.toLowerCase() != 'hawk'
        return null
      attributesString = headerParts[2]
      if !attributesString
        return null
      attributes = {}
      verify = attributesString.replace(/(\w+)="([^"\\]*)"\s*(?:,\s*|$)/g, ($0, $1, $2) ->
        if keys.indexOf($1) == -1
          return
        if $2.match(/^[ \w\!#\$%&'\(\)\*\+,\-\.\/\:;<\=>\?@\[\]\^`\{\|\}~]+$/) == null
          return
        if attributes.hasOwnProperty($1)
          return
        attributes[$1] = $2
        ''
      )
      if verify != ''
        return null
      attributes
    randomString: (size) ->
      i = undefined
      len = undefined
      randomSource = undefined
      result = undefined
      randomSource = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
      len = randomSource.length
      result = []
      i = 0
      while i < size
        result[i] = randomSource[Math.floor(Math.random() * len)]
        ++i
      result.join ''
    parseUri: (input) ->
      i = undefined
      il = undefined
      keys = undefined
      uri = undefined
      uriByNumber = undefined
      uriRegex = undefined
      keys = [
        'source'
        'protocol'
        'authority'
        'userInfo'
        'user'
        'password'
        'hostname'
        'port'
        'resource'
        'relative'
        'pathname'
        'directory'
        'file'
        'query'
        'fragment'
      ]
      uriRegex = /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?(((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?)(?:#(.*))?)/
      uriByNumber = input.match(uriRegex)
      uri = {}
      i = 0
      il = keys.length
      while i < il
        uri[keys[i]] = uriByNumber[i] or ''
        ++i
      if uri.port == ''
        uri.port = if uri.protocol.toLowerCase() == 'http' then '80' else if uri.protocol.toLowerCase() == 'https' then '443' else ''
      uri
    base64urlEncode: (value) ->
      encoded = undefined
      wordArray = undefined
      wordArray = CryptoJS.enc.Utf8.parse(value)
      encoded = CryptoJS.enc.Base64.stringify(wordArray)
      encoded.replace(/\+/g, '-').replace(/\//g, '_').replace /\=/g, ''
  @crypto.internals = CryptoJS
  return
 ]

# ---
# generated by js2coffee 2.0.3
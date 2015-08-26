var getCookie, ngMeditab;

ngMeditab = angular.module('ngMeditab', ['ngRoute']);

ngMeditab.factory('ApiObject', [
  "$http", "meditabApiUrl", "apiUtils", 'hawk', 'hawkCredentials', 'hawkCredentialsDynamic', function($http, meditabApiUrl, apiUtils, hawk, hawkCredentials, hawkCredentialsDynamic) {

    /*
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
     */
    var AO, REQUEST;
    REQUEST = function(url, method, data) {
      this.url = url;
      this.method = method;
      this.data = data;
      this.params = [];
    };
    REQUEST.prototype.limit = function(int) {
      if (int !== void 0 || int !== null) {
        this.params.push("limit=" + int);
      }
      return this;
    };
    REQUEST.prototype.sort = function(key) {
      if (key) {
        this.params.push("sort=" + key);
      }
      return this;
    };
    REQUEST.prototype.populate = function(key) {
      if (key) {
        this.params.push("populate=" + key);
      }
      return this;
    };
    REQUEST.prototype.page = function(int) {
      if (int !== void 0 || int !== null) {
        this.params.push("page=" + int);
      }
      return this;
    };
    REQUEST.prototype.skip = function(int) {
      if (int !== void 0 || int !== null) {
        this.params.push("skip=" + int);
      }
      return this;
    };
    REQUEST.prototype.exec = function(callback) {
      var ajax, config, credentials, header, url;
      url = meditabApiUrl.api + (meditabApiUrl.port !== 80 ? ":" + meditabApiUrl.port : "") + "/" + this.url;
      if (this.params.length) {
        url += "?" + this.params.join("&");
      }
      credentials = hawkCredentialsDynamic.get();
      if (!credentials) {
        credentials = hawkCredentials;
      }
      header = hawk.client.header(url, this.method, {
        credentials: credentials
      });
      ajax = null;
      config = {
        method: this.method,
        url: url,
        headers: {
          'Authorization': header.field
        }
      };
      if (this.data) {
        config.data = this.data;
      }
      ajax = $http(config);
      return ajax.success(function(data) {
        return callback(null, (data.rows ? data.rows : data));
      }).error(function(error) {
        if (console.error) {
          console.error(error);
        }
        return callback(error);
      });
    };
    AO = function(name) {
      return this.name = name;
    };
    AO.prototype.get = function(url) {
      var req;
      req = new REQUEST(url, "get");
      return req;
    };
    AO.prototype.post = function(url, data) {
      var req;
      req = new REQUEST(url, "post");
      if (data) {
        req.data = data;
      }
      return req;
    };
    AO.prototype.put = function(url, data) {
      var req;
      req = new REQUEST(url, "put");
      if (data) {
        req.data = data;
      }
      return req;
    };
    AO.prototype.del = function(url) {
      var req;
      req = new REQUEST(url, "delete");
      return req;
    };
    AO.prototype.show = function(id) {
      var url;
      url = this.name + "/show/" + id;
      return this.get(url);
    };
    AO.prototype.list = function() {
      var url;
      url = this.name + "/list";
      return this.get(url);
    };
    AO.prototype.find = function(query) {
      var req, url;
      url = this.name + "/search";
      req = this.get(url);
      req.params.push("q=" + apiUtils.serialize(query));
      return req;
    };
    AO.prototype.create = function(data) {
      var url;
      url = this.name + "/create";
      return this.post(url, data);
    };
    AO.prototype.update = function(id, data) {
      var url;
      url = this.name + "/update/" + id;
      return this.put(url, data);
    };
    AO.prototype["delete"] = function(id) {
      var url;
      url = this.name + "/remove/" + id;
      return this.del(url);
    };
    return AO;
  }
]);

ngMeditab.service('apiUtils', [
  function() {
    this.serialize = function(obj) {
      return encodeURIComponent(JSON.stringify(obj));
    };
  }
]);

ngMeditab.factory('hawkInterceptor', [
  'hawk', 'hawkCredentials', 'hawkCredentialsDynamic', 'meditabApiUrl', function(hawk, hawkCredentials, hawkCredentialsDynamic, meditabApiUrl) {
    var hawkInterceptor;
    hawkInterceptor = void 0;
    hawkInterceptor = {
      request: function(config) {
        var url;
        url = config.url;
        if (url && url.indexOf(meditabApiUrl.api) === -1) {
          config.headers['ajax'] = true;
        }
        return config;
      }
    };
    return hawkInterceptor;
  }
]);

ngMeditab.service("hawkCredentialsRenewer", [
  "$http", "hawkCredentialsDynamic", "$timeout", "meditabApiUrl", function($http, hawkCredentialsDynamic, $timeout, meditabApiUrl) {
    this.renew = function() {
      var renewer;
      renewer = this;
      return $http.get(meditabApiUrl.renewCredential).success(function(data) {
        if (data.id) {
          hawkCredentialsDynamic.set(data);
          return renewer.timer(data.ms);
        } else {

          /*
            user might not be logged in
            return to homepage
           */
        }
      });
    };
    this.timer = function(ms) {
      var renewer;
      renewer = this;
      return $timeout(function() {
        return renewer.renew();
      }, ms);
    };
    this.start = function() {
      var renewer;
      renewer = this;
      return $http.get(meditabApiUrl.expiration).success(function(data) {
        var credential;
        if (data.id) {

          /*
            means data expired already
           */
          credential = {
            id: data.id,
            key: data.key
          };
          hawkCredentialsDynamic.set(credential);
          return renewer.timer(data.ms);
        } else {
          return renewer.timer(data.ms);
        }
      });
    };
  }
]);

ngMeditab.service("hawkCredentialsDynamic", [
  function() {
    var credentials;
    credentials = {
      id: false,
      key: false,
      algorithm: 'sha256'
    };
    this.set = function(data) {
      credentials.id = data.id;
      return credentials.key = data.key;
    };
    this.get = function() {
      var c;
      c = credentials;
      if (!c.id || !c.key) {
        c = false;
      }
      return c;
    };
  }
]);

ngMeditab.provider('hawkCredentials', [
  function() {
    var credentials;
    credentials = {
      algorithm: 'sha256',
      key: 'none',
      id: false
    };
    this.set = function(c) {
      credentials.id = c.id;
      credentials.key = c.key;
    };
    this.$get = function() {
      return credentials;
    };
  }
]);

ngMeditab.provider('meditabApiUrl', [
  function() {
    var config;
    config = {
      api: "api.meditab.com",
      port: 80,
      getCredential: "/apicredential/get",
      renewCredential: "/apicredential/renew",
      expiration: "/apicredential/expiration"
    };
    this.set = function(newConfig) {
      var key, results;
      results = [];
      for (key in newConfig) {
        results.push(config[key] = newConfig[key]);
      }
      return results;
    };
    this.$get = function() {
      return config;
    };
  }
]);

getCookie = function(cname) {
  var c, ca, i, name;
  name = cname + '=';
  ca = document.cookie.split(';');
  i = 0;
  while (i < ca.length) {
    c = ca[i];
    while (c.charAt(0) === ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) === 0) {
      return c.substring(name.length, c.length);
    }
    i++;
  }
  return '';
};

ngMeditab.config([
  '$routeProvider', '$locationProvider', '$httpProvider', '$sceDelegateProvider', 'meditabApiUrlProvider', 'hawkCredentialsProvider', function($routeProvider, $locationProvider, $httpProvider, $sceDelegateProvider, meditabApiUrlProvider, hawkCredentialsProvider) {
    var credentials;
    $httpProvider.interceptors.push('hawkInterceptor');
    $httpProvider.defaults.transformRequest.push(function(data, headersGetter) {
      var d, utf8_data;
      d = void 0;
      utf8_data = void 0;
      utf8_data = data;
      if (!angular.isUndefined(data)) {
        d = angular.fromJson(data);
        d['utf8'] = '&#9731;';
        utf8_data = angular.toJson(d);
      }
      return utf8_data;
    });
    $sceDelegateProvider.resourceUrlWhitelist(['self', 'http://' + meditabApiUrlProvider.api + '/**']);
    credentials = {
      id: decodeURIComponent(getCookie('tempId')),
      key: getCookie('tempKey')
    };
    if (credentials.id && credentials.key) {
      hawkCredentialsProvider.set(credentials);
    }
  }
]);

ngMeditab.run([
  '$http', 'meditabApiUrl', 'hawkCredentialsRenewer', function($http, meditabApiUrl, hawkCredentialsRenewer) {

    /*
    if credential is not set in the cookie 
    request credential via ajax
     */
    var credentials;
    credentials = {
      id: decodeURIComponent(getCookie('tempId')),
      key: getCookie('tempKey')
    };
    if (!credentials.id || !credentials.key) {
      $http.get(meditabApiUrl.getCredential).success(function(data) {
        if (data.id && data.key) {
          return hawkCredentialsDynamic.set(data);
        }
      });
    }
    hawkCredentialsRenewer.start();
  }
]);

ngMeditab.service('hawk', [
  function() {
    var hawk;
    hawk = this;
    this.internals = {};
    this.client = {
      header: function(uri, method, options) {
        var artifacts, credentials, hasExt, header, mac, result, timestamp;
        artifacts = void 0;
        hasExt = void 0;
        header = void 0;
        mac = void 0;
        result = void 0;
        timestamp = void 0;
        result = {
          field: '',
          artifacts: {}
        };
        if (!uri || typeof uri !== 'string' && typeof uri !== 'object' || !method || typeof method !== 'string' || !options || typeof options !== 'object') {
          result.err = 'Invalid argument type';
          return result;
        }
        timestamp = options.timestamp || hawk.utils.now(options.localtimeOffsetMsec);
        credentials = options.credentials;
        if (!credentials || !credentials.id || !credentials.key || !credentials.algorithm) {
          result.err = 'Invalid credentials object';
          return result;
        }
        if (hawk.crypto.algorithms.indexOf(credentials.algorithm) === -1) {
          result.err = 'Unknown algorithm';
          return result;
        }
        if (typeof uri === 'string') {
          uri = hawk.utils.parseUri(uri);
        }
        artifacts = {
          ts: timestamp,
          nonce: options.nonce || hawk.utils.randomString(6),
          method: method,
          resource: uri.relative,
          host: uri.hostname,
          port: uri.port,
          hash: options.hash,
          ext: options.ext,
          app: options.app,
          dlg: options.dlg
        };
        result.artifacts = artifacts;
        if (!artifacts.hash && (options.payload || options.payload === '')) {
          artifacts.hash = hawk.crypto.calculatePayloadHash(options.payload, credentials.algorithm, options.contentType);
        }
        mac = hawk.crypto.calculateMac('header', credentials, artifacts);
        hasExt = artifacts.ext !== null && artifacts.ext !== void 0 && artifacts.ext !== '';
        header = 'Hawk id="' + credentials.id + '", ts="' + artifacts.ts + '", nonce="' + artifacts.nonce + (artifacts.hash ? '", hash="' + artifacts.hash : '') + (hasExt ? '", ext="' + hawk.utils.escapeHeaderAttribute(artifacts.ext) : '') + '", mac="' + mac + '"';
        if (artifacts.app) {
          header += ', app="' + artifacts.app + (artifacts.dlg ? '", dlg="' + artifacts.dlg : '') + '"';
        }
        result.field = header;
        return result;
      },
      bewit: function(uri, options) {
        var bewit, credentials, exp, mac, now;
        bewit = void 0;
        exp = void 0;
        mac = void 0;
        now = void 0;
        if (!uri || typeof uri !== 'string' || !options || typeof options !== 'object' || !options.ttlSec) {
          return '';
        }
        options.ext = options.ext === null || options.ext === void 0 ? '' : options.ext;
        now = hawk.utils.now(options.localtimeOffsetMsec);
        credentials = options.credentials;
        if (!credentials || !credentials.id || !credentials.key || !credentials.algorithm) {
          return '';
        }
        if (hawk.crypto.algorithms.indexOf(credentials.algorithm) === -1) {
          return '';
        }
        uri = hawk.utils.parseUri(uri);
        exp = now + options.ttlSec;
        mac = hawk.crypto.calculateMac('bewit', credentials, {
          ts: exp,
          nonce: '',
          method: 'GET',
          resource: uri.relative,
          host: uri.hostname,
          port: uri.port,
          ext: options.ext
        });
        bewit = credentials.id + '\\' + exp + '\\' + mac + '\\' + options.ext;
        return hawk.utils.base64urlEncode(bewit);
      },
      authenticate: function(request, credentials, artifacts, options) {
        var attributes, calculatedHash, getHeader, mac, modArtifacts, serverAuthorization, tsm, wwwAuthenticate;
        attributes = void 0;
        calculatedHash = void 0;
        getHeader = void 0;
        mac = void 0;
        modArtifacts = void 0;
        serverAuthorization = void 0;
        tsm = void 0;
        wwwAuthenticate = void 0;
        options = options || {};
        getHeader = function(name) {
          var attributes;
          attributes = void 0;
          if (request.getResponseHeader) {
            return request.getResponseHeader(name);
          } else {
            return request.getHeader(name);
          }
        };
        wwwAuthenticate = getHeader('www-authenticate');
        if (wwwAuthenticate) {
          attributes = hawk.utils.parseAuthorizationHeader(wwwAuthenticate, ['ts', 'tsm', 'error']);
          if (!attributes) {
            return false;
          }
          if (attributes.ts) {
            tsm = hawk.crypto.calculateTsMac(attributes.ts, credentials);
            if (tsm !== attributes.tsm) {
              return false;
            }
            hawk.utils.setNtpOffset(attributes.ts - Math.floor((new Date).getTime() / 1000));
          }
        }
        serverAuthorization = getHeader('server-authorization');
        if (!serverAuthorization && !options.required) {
          return true;
        }
        attributes = hawk.utils.parseAuthorizationHeader(serverAuthorization, ['mac', 'ext', 'hash']);
        if (!attributes) {
          return false;
        }
        modArtifacts = {
          ts: artifacts.ts,
          nonce: artifacts.nonce,
          method: artifacts.method,
          resource: artifacts.resource,
          host: artifacts.host,
          port: artifacts.port,
          hash: attributes.hash,
          ext: attributes.ext,
          app: artifacts.app,
          dlg: artifacts.dlg
        };
        mac = hawk.crypto.calculateMac('response', credentials, modArtifacts);
        if (mac !== attributes.mac) {
          return false;
        }
        if (!options.payload && options.payload !== '') {
          return true;
        }
        if (!attributes.hash) {
          return false;
        }
        calculatedHash = hawk.crypto.calculatePayloadHash(options.payload, credentials.algorithm, getHeader('content-type'));
        return calculatedHash === attributes.hash;
      },
      message: function(host, port, message, options) {
        var artifacts, credentials, result, timestamp;
        artifacts = void 0;
        result = void 0;
        timestamp = void 0;
        if (!host || typeof host !== 'string' || !port || typeof port !== 'number' || message === null || message === void 0 || typeof message !== 'string' || !options || typeof options !== 'object') {
          return null;
        }
        timestamp = options.timestamp || hawk.utils.now(options.localtimeOffsetMsec);
        credentials = options.credentials;
        if (!credentials || !credentials.id || !credentials.key || !credentials.algorithm) {
          return null;
        }
        if (hawk.crypto.algorithms.indexOf(credentials.algorithm) === -1) {
          return null;
        }
        artifacts = {
          ts: timestamp,
          nonce: options.nonce || hawk.utils.randomString(6),
          host: host,
          port: port,
          hash: hawk.crypto.calculatePayloadHash(message, credentials.algorithm)
        };
        result = {
          id: credentials.id,
          ts: artifacts.ts,
          nonce: artifacts.nonce,
          hash: artifacts.hash,
          mac: hawk.crypto.calculateMac('message', credentials, artifacts)
        };
        return result;
      },
      authenticateTimestamp: function(message, credentials, updateClock) {
        var tsm;
        tsm = void 0;
        tsm = hawk.crypto.calculateTsMac(message.ts, credentials);
        if (tsm !== message.tsm) {
          return false;
        }
        if (updateClock !== false) {
          hawk.utils.setNtpOffset(message.ts - Math.floor((new Date).getTime() / 1000));
        }
        return true;
      }
    };
    this.crypto = {
      headerVersion: '1',
      algorithms: ['sha1', 'sha256'],
      calculateMac: function(type, credentials, options) {
        var hmac, normalized;
        hmac = void 0;
        normalized = void 0;
        normalized = hawk.crypto.generateNormalizedString(type, options);
        hmac = CryptoJS['Hmac' + credentials.algorithm.toUpperCase()](normalized, credentials.key);
        return hmac.toString(CryptoJS.enc.Base64);
      },
      generateNormalizedString: function(type, options) {
        var normalized;
        normalized = void 0;
        normalized = 'hawk.' + hawk.crypto.headerVersion + '.' + type + '\n' + options.ts + '\n' + options.nonce + '\n' + (options.method || '').toUpperCase() + '\n' + (options.resource || '') + '\n' + options.host.toLowerCase() + '\n' + options.port + '\n' + (options.hash || '') + '\n';
        if (options.ext) {
          normalized += options.ext.replace('\\', '\\\\').replace('\n', '\\n');
        }
        normalized += '\n';
        if (options.app) {
          normalized += options.app + '\n' + (options.dlg || '') + '\n';
        }
        return normalized;
      },
      calculatePayloadHash: function(payload, algorithm, contentType) {
        var hash;
        hash = void 0;
        hash = CryptoJS.algo[algorithm.toUpperCase()].create();
        hash.update('hawk.' + hawk.crypto.headerVersion + '.payload\n');
        hash.update(hawk.utils.parseContentType(contentType) + '\n');
        hash.update(payload);
        hash.update('\n');
        return hash.finalize().toString(CryptoJS.enc.Base64);
      },
      calculateTsMac: function(ts, credentials) {
        var hash;
        hash = void 0;
        hash = CryptoJS['Hmac' + credentials.algorithm.toUpperCase()]('hawk.' + hawk.crypto.headerVersion + '.ts\n' + ts + '\n', credentials.key);
        return hash.toString(CryptoJS.enc.Base64);
      }
    };
    this.internals.LocalStorage = function() {
      this._cache = {};
      this.length = 0;
      this.getItem = function(key) {
        if (this._cache.hasOwnProperty(key)) {
          return String(this._cache[key]);
        } else {
          return null;
        }
      };
      this.setItem = function(key, value) {
        this._cache[key] = String(value);
        this.length = Object.keys(this._cache).length;
      };
      this.removeItem = function(key) {
        delete this._cache[key];
        this.length = Object.keys(this._cache).length;
      };
      this.clear = function() {
        this._cache = {};
        this.length = 0;
      };
      this.key = function(i) {
        return Object.keys(this._cache)[i || 0];
      };
    };
    this.utils = {
      storage: new hawk.internals.LocalStorage,
      setStorage: function(storage) {
        var ntpOffset;
        ntpOffset = void 0;
        ntpOffset = hawk.utils.storage.getItem('hawk_ntp_offset');
        hawk.utils.storage = storage;
        if (ntpOffset) {
          hawk.utils.setNtpOffset(ntpOffset);
        }
      },
      setNtpOffset: function(offset) {
        var _error, err;
        err = void 0;
        try {
          hawk.utils.storage.setItem('hawk_ntp_offset', offset);
        } catch (_error) {
          _error = _error;
          err = _error;
          console.error('[hawk] could not write to storage.');
          console.error(err);
        }
      },
      getNtpOffset: function() {
        var offset;
        offset = void 0;
        offset = hawk.utils.storage.getItem('hawk_ntp_offset');
        if (!offset) {
          return 0;
        }
        return parseInt(offset, 10);
      },
      now: function(localtimeOffsetMsec) {
        return Math.floor(((new Date).getTime() + (localtimeOffsetMsec || 0)) / 1000) + hawk.utils.getNtpOffset();
      },
      escapeHeaderAttribute: function(attribute) {
        return attribute.replace(/\\/g, '\\\\').replace(/\"/g, '"');
      },
      parseContentType: function(header) {
        if (!header) {
          return '';
        }
        return header.split(';')[0].replace(/^\s+|\s+$/g, '').toLowerCase();
      },
      parseAuthorizationHeader: function(header, keys) {
        var attributes, attributesString, headerParts, scheme, verify;
        attributes = void 0;
        attributesString = void 0;
        headerParts = void 0;
        scheme = void 0;
        verify = void 0;
        if (!header) {
          return null;
        }
        headerParts = header.match(/^(\w+)(?:\s+(.*))?$/);
        if (!headerParts) {
          return null;
        }
        scheme = headerParts[1];
        if (scheme.toLowerCase() !== 'hawk') {
          return null;
        }
        attributesString = headerParts[2];
        if (!attributesString) {
          return null;
        }
        attributes = {};
        verify = attributesString.replace(/(\w+)="([^"\\]*)"\s*(?:,\s*|$)/g, function($0, $1, $2) {
          if (keys.indexOf($1) === -1) {
            return;
          }
          if ($2.match(/^[ \w\!#\$%&'\(\)\*\+,\-\.\/\:;<\=>\?@\[\]\^`\{\|\}~]+$/) === null) {
            return;
          }
          if (attributes.hasOwnProperty($1)) {
            return;
          }
          attributes[$1] = $2;
          return '';
        });
        if (verify !== '') {
          return null;
        }
        return attributes;
      },
      randomString: function(size) {
        var i, len, randomSource, result;
        i = void 0;
        len = void 0;
        randomSource = void 0;
        result = void 0;
        randomSource = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        len = randomSource.length;
        result = [];
        i = 0;
        while (i < size) {
          result[i] = randomSource[Math.floor(Math.random() * len)];
          ++i;
        }
        return result.join('');
      },
      parseUri: function(input) {
        var i, il, keys, uri, uriByNumber, uriRegex;
        i = void 0;
        il = void 0;
        keys = void 0;
        uri = void 0;
        uriByNumber = void 0;
        uriRegex = void 0;
        keys = ['source', 'protocol', 'authority', 'userInfo', 'user', 'password', 'hostname', 'port', 'resource', 'relative', 'pathname', 'directory', 'file', 'query', 'fragment'];
        uriRegex = /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?(((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?)(?:#(.*))?)/;
        uriByNumber = input.match(uriRegex);
        uri = {};
        i = 0;
        il = keys.length;
        while (i < il) {
          uri[keys[i]] = uriByNumber[i] || '';
          ++i;
        }
        if (uri.port === '') {
          uri.port = uri.protocol.toLowerCase() === 'http' ? '80' : uri.protocol.toLowerCase() === 'https' ? '443' : '';
        }
        return uri;
      },
      base64urlEncode: function(value) {
        var encoded, wordArray;
        encoded = void 0;
        wordArray = void 0;
        wordArray = CryptoJS.enc.Utf8.parse(value);
        encoded = CryptoJS.enc.Base64.stringify(wordArray);
        return encoded.replace(/\+/g, '-').replace(/\//g, '_').replace(/\=/g, '');
      }
    };
    this.crypto.internals = CryptoJS;
  }
]);

//# sourceMappingURL=ngMeditab.js.map

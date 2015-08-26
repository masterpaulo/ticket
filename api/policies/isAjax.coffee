module.exports = (req, res, next) ->
  url = req.url
  exception = false
  except = [
    "auth/authenticate"
    "styles/"
    "js/"
  ]
  except.forEach (ex)->
    exception = true if url.indexOf(ex) isnt -1
  if req.headers["ajax"] or url is "/login" or url is "/logout" or exception
    next()
  else #login or logout
    View.render req, res
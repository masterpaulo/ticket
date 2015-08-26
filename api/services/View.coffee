roles = [
  {view:"home",id:null}
  {view:"superuser",id:34}
  {view:"administrator",id:33}
  {view:"employee",id:32}
  # {view:"spectator",id:28}
]
View =
  render: (req, res) ->
    base      = req.headers.host
    userData = req.session.passport
    if req.session.passport.apiId
      res.cookie "tempId",req.session.passport.user.apiId,
        maxAge: 30 * 60 * 1000
      res.cookie "tempKey",req.session.passport.user.apiKey,
        maxAge: 30 * 60 * 1000
    if userData and userData.active
      ###
      determine the active sessionType this user is using
      ###

      # console.log userData
      # console.log userData.user.roles

      res.cookie "expirationAccess", userData.active.roleId,
        maxAge: 30 * 60 * 1000
      res.cookie "userAccess", userData.user.appuser,
        maxAge: 30 * 60 * 1000

      idx = roles.map (e)->
        return e.id
      .indexOf userData.active.roleId

      res.view roles[idx].view, base:base
    else
      p = require "../../package.json"
      res.view roles[0].view, {
        version: p.version
        base:base
      }

module.exports = View

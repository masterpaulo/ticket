roles = [
  {view:"home",id:null}
  {view:"superuser",id:34}
  {view:"administrator",id:33}

  {view:"employee",id:32}
  # {view:"spectator",id:28}
]

module.exports =
  types: (req, res) ->

    roleIds = roles.map (r)->
      return r.id
    userRoles = Copy req.session.passport.user.roles
    userRoles.forEach (r)->
      i = roleIds.indexOf r.roleId
      if i > 0
        r.name = roles[i].view
      return
    res.json userRoles

  change: (req, res) ->
    id        = +req.param 'id'
    active    = req.session.passport.active
    userRoles = req.session.passport.user.roles

    if active.roleId is id
      res.json success: false
    else
      result = false
      userRoles.forEach (each) ->
        if each.roleId is id
          req.session.passport.active      = each
          req.session.passport.user.active = each
          result = true
          return false
      res.json success: result

  check: (req, res) ->
    res.json req.session.passport.user

  token: (req, res) ->
    res.json req.session.passport.user.token

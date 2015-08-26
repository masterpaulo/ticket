passwordHash    = require('phpass').PasswordHash
ncrypt          = new passwordHash()
passport        = require "passport"
api             = require("api-sdk")

module.exports =
  view:(req,res)->
    View.render(req)
  logout: (req, res) ->
    req.logout()
    req.session.destroy()
    res.redirect '/'

  login: (req, res) ->

    passport.authenticate("local", (err, user, info) ->
      if err or user is false
        return res.redirect "/" # go back to login page and display error
      req.logIn user, (err) ->

        roleIds = user.roles.map (e)->
          return e.roleId

        r = Math.min.apply null,roleIds
        ri = roleIds.indexOf r

        req.session.passport.active          = user.roles[ri]
        req.session.passport.user.active     = user.roles[ri]
        req.session.passport.user.lastActive = new Date()
        req.session.passport.lastActive      = new Date()
        res.cookie "user", req.session.passport.user.appuser,
          maxAge: 12 * 60 * 60 * 1000
        res.cookie "tempId",req.session.passport.user.apiId,
          maxAge: 30 * 60 * 1000
        res.cookie "tempKey",req.session.passport.user.apiKey,
          maxAge: 30 * 60 * 1000
        res.cookie "company", req.session.passport.user.company,
          maxAge: 9999999999
        res.redirect "/"
    ) req, res
  password: (req,res)->
    data = req.body
    user = UserData(req).id

    if data.newPassword is data.newPasswordCopy
      User.findOneById user
      .exec (err,user)->
        if err
          res.json message:err
        else
          if ncrypt.checkPassword(data.password, user.password)
            user.password = data.newPassword
            user.save (err)->
              res.json success:true
          else
            res.json message:"password provided does not match existing password"

    else
      res.json message:"password does not match"

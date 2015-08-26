api = require("api-sdk")

module.exports =
  get: (req,res)->

    obj =

      id: "55d3e4770c7f4dee47b668c8"
      key: "wwPY_j.NZRLa3onz6z5zzUy-UejpYPDaxTqYs85C"

      # id: "554c7840c0fb4b1f0eab8f11"
      # key: "R_Ayx4NyyYfm_RcetEce"
    res.json obj

  renew:(req,res)->
    DEFAULT_RENEW_EXPIRATION = 2
    ###
      get renew key from current session then request for a new key from the Meditab API server

    ###
    data =
      appuser: req.session.passport.user.appuser
      expiration: DEFAULT_RENEW_EXPIRATION

    if data.appuser
      api.renew data, (result)->
        if result.resObj
          res.json result.resObj
        else
          res.json success:false
      ###Api "POST","/user/renew",data, (err,result)->
        if err
          res.serverError err
        else
          newId = result.apiId
          newKey = result.apiKey

          # DONT EVER FORGET TO ADD THIS COOKIES
          keyExpiration = DEFAULT_RENEW_EXPIRATION * 60 * 1000
          res.cookie "tempId",newId,
            maxAge: keyExpiration
          res.cookie "tempKey",newKey,
            maxAge: keyExpiration
          res.cookie "tempIdExpiration", DEFAULT_RENEW_EXPIRATION,
            maxAge: keyExpiration

          # UPDATE SESSION DATA with lated tempId and tempKey for api
          req.session.passport.apiId = newId
          req.session.passport.apiKey = newKey
          req.session.passport.tempIdCreatedAt = new Date()

          obj =
              id: newId
              key: newKey
              ms: keyExpiration - 60000

          res.json obj###
    else
      obj =
        success: false
      res.json obj

  expiration: (req,res)->
    # Expiration in minutes of new api access
    DEFAULT_RENEW_EXPIRATION = 5

    ###
      TIME_ID_WAS_CREATED   = req.session.passport.tempIdCreatedAt
      EXPIRATION_TIME       = req.session.passport.tempIdExpiration
      TIME_NOW              = new Date()

      timeLeft = EXPIRATION_TIME - ( TIME_NOW - TIME_ID_WAS_CREATED )
      if timeLeft < 1 minute
        renew and send credentials to front-end together with `ms` as response
      else
        respond with `ms` as timeLeft
    ###
    UserData = req.session.passport
    if UserData.tempIdExpiration and UserData.tempIdCreatedAt

      tempIdCreatedAt = new Date UserData.tempIdCreatedAt
      tempIdExpiration = UserData.tempIdExpiration
      now = new Date()

      timeLeft = ((tempIdExpiration*60*1000) - (now - tempIdCreatedAt)) / (60 * 1000)
      if timeLeft < 1
        Api "POST","/user/renew", (err,result)->
          if err
            res.serverError err
          else
            newId = result.apiId
            newKey = result.apiKey

            # DONT EVER FORGET TO ADD THIS COOKIES
            keyExpiration = DEFAULT_RENEW_EXPIRATION * 60 * 1000

            res.cookie "tempId",newId,
              maxAge: keyExpiration
            res.cookie "tempKey",newKey,
              maxAge: keyExpiration
            res.cookie "tempIdExpiration", DEFAULT_RENEW_EXPIRATION,
              maxAge: keyExpiration

            # UPDATE SESSION DATA with lated tempId and tempKey for api
            req.session.passport.apiId = newId
            req.session.passport.apiKey = newKey
            req.session.passport.tempIdCreatedAt = new Date()

            obj =
              id: newId
              key: newKey
              ms: keyExpiration - 60000

            req.session.tempIdExpiration = DEFAULT_RENEW_EXPIRATION

            res.json obj
      else
        res.json ms: (timeLeft - 1)*60*1000
    else
      res.json ms:0

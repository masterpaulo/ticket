###
AlertController

@description :: Server-side logic for managing scopes
@help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports = {

  list: (req,res)->
    Alert.find().exec (err,data)->
      res.json data

  create: (req,res)->
    console.log "creating an alert "
    console.log req.body
    Alert.create req.body
    .exec (err,data)->
      if err
        res.json error:err
      else
        res.json data

  destroy: (req,res)->
    Alert.destroy id:req.param "id"
    .exec (err,data)->
      if err
        res.json error:err
      else
        res.json data[0]


}


###
ReceiverController

@description :: Server-side logic for managing scopes
@help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports = {

  list: (req,res)->
    Receiver.find().exec (err,data)->
      res.json data

  create: (req,res)->
    Receiver.create req.body
    .exec (err,data)->
      if err
        res.json error:err
      else
        res.json data

  destroy: (req,res)->
    Receiver.destroy id:req.param "id"
    .exec (err,data)->
      if err
        res.json error:err
      else
        res.json data[0]


}


###
RequestController

@description :: Server-side logic for managing scopes
@help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports = {

  list: (req,res)->
    Request.find().exec (err,data)->
      res.json data

  create: (req,res)->
    Request.create req.body
    .exec (err,data)->
      if err
        res.json error:err
      else
        res.json data

  destroy: (req,res)->
    Request.destroy id:req.param "id"
    .exec (err,data)->
      if err
        res.json error:err
      else
        res.json data[0]



}


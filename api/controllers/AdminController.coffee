###
AdminController

@description :: Server-side logic for managing scopes
@help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports = {

  list: (req,res)->
    Admin.find().exec (err,data)->
      res.json data

  create: (req,res)->
    Admin.create req.body
    .exec (err,data)->
      if err
        res.json error:err
      else
        res.json data

  destroy: (req,res)->
    Admin.destroy id:req.param "id"
    .exec (err,data)->
      if err
        res.json error:err
      else
        res.json data[0]

  searchByScopeId: (req, res) ->
    find = req.body.id
    console.log find
    #Admin.find({scopeId:find})

}


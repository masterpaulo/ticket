###
CommentController

@description :: Server-side logic for managing scopes
@help        :: See http://links.sailsjs.org/docs/controllers
###

module.exports = {

  list: (req,res)->
    Comment.find().exec (err,data)->
      res.json data

  create: (req,res)->
    Comment.create req.body
    .exec (err,data)->
      if err
        res.json error:err
      else
        res.json data

  destroy: (req,res)->
    Comment.destroy id:req.param "id"
    .exec (err,data)->
      if err
        res.json error:err
      else
        res.json data[0]



}


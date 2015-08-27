# Comment.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
  adapter: 'mongo'
  attributes:



    message:
      type: 'string'
      defaultsTo: ''

    requestId:
      type: 'integer'
      model: 'Request'

    userId:
      type: 'integer'



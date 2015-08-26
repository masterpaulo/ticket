# Request.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
  adapter: 'mongo'
  attributes:

    name:
      type: 'string'
      defaultsTo: ''
    description:
      type: 'string'
      defaultsTo: ''
    statusId:
      type: 'integer'
      model: 'Status'

    concernId:
      type: 'integer'
      model: 'Concern'

    userId:
      type: 'integer'
      model: 'User'

    comments:
      collection: 'comment'
      via: 'requestId'



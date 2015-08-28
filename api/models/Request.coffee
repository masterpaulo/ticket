# Request.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
  adapter: 'mongo'
  attributes:

    title:
      type: 'string'
      defaultsTo: ''
    description:
      type: 'string'
      defaultsTo: ''

    scopeId:
      type: 'integer'
      model: 'Scope'

    statusId:
      type: 'integer'
      model: 'Status'

    concernId:
      type: 'integer'
      model: 'Concern'

    userId:
      type: 'integer'

    comments:
      collection: 'comment'
      via: 'requestId'


    alerts:
      collection: 'alert'
      via: 'requestId'

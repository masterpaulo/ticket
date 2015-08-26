 # Scope.coffee
 #
 # @description :: TODO: You might write a short summary of how this model works and what it represents here.
 # @docs        :: http://sailsjs.org/#!documentation/models

module.exports =
  adapter: 'mongo'
  attributes:

    name:
      type: 'string'
      defaultsTo: ''
      unique: true

    admins:
      collection: 'admin'
      via: 'scopeId'

    concerns:
      collection: 'concern'
      via: 'scopeId'

    status:
      collection: 'status'
      via: 'scopeId'



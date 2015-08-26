module.exports =
  adapter: 'mongo'
  attributes:

    name:
      type: 'string'
      defaultsTo: ''

    scopeId:
      type: 'integer'
      model: 'scope'

    requests:
      collection: 'request'
      via: 'concernId'


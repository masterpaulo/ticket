module.exports =
  adapter: 'mongo'
  attributes:

    type:
      type: 'string'
      enum: ['status', 'comment', 'request']
      defaultsTo: 'status alert'
    message:
      type: 'string'
      defaultsTo: ''

    viewed:
      type: "boolean"

    receivers:
      collection: "receiver"
      via: 'alertId'

    userId:
      type: 'integer'
      defaultsTo: 0

    roleId:
      type: 'integer'
      defaultsTo: 0

    requestId:
      type: 'integer'
      model: 'request'
      defaultsTo: 0


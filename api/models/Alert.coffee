module.exports =
  adapter: 'mongo'
  attributes:

    type:
      type: 'string'
      enum: ['status alert', 'comment alert']
      defaultsTo: 'status alert'
    message:
      type: 'string'
      defaultsTo: ''

    viewed:
      type: "boolean"

    receivers:
      type: "ARRAY"

    userId:
      model: 'user'

    requestId:
      model: 'request'


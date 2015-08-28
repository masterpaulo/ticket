module.exports =
  adapter: 'mongo'
  attributes:

    viewed:
      type: "boolean"
      defaultsTo: false

    userId:
      type: 'integer'

    alertId:
      type: 'integer'
      model: 'Alert'


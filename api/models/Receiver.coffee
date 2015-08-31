module.exports =
  adapter: 'mongo'
  attributes:

    viewed:
      type: "boolean"
      defaultsTo: false

    userId:
      type: 'integer'
      defaultsTo: 0

    roleId:
      type: 'integer'
      defaultsTo: 0

    alertId:
      type: 'integer'
      model: 'Alert'


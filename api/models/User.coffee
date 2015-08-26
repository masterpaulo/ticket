module.exports =
  adapter: 'mongo'
  attributes:
    provider: 'STRING'
    uid: 'STRING'
    name: 'STRING'
    email: 'STRING'
    firstname: 'STRING'
    lastname: 'STRING'
    role:
      type:"INTEGER"
      defaultsTo: 0
    shift:
      defaultsTo: 0
      type:"INTEGER"

    alerts:
      collection: 'alert'
      via: 'userId'

    comments:
      collection: 'comment'
      via: 'userId'

    requests:
      collection: 'request'
      via: 'userId'

    admins:
      collection: 'admin'
      via: 'userId'

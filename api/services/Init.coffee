module.exports =
  admin:->
    admin =
      email: "kpi-master@meditab.com"
      password: "test"
      role: 3
    User.create admin
    .exec (err,data)->
      console.log "admin has been created" if data
  reset:->
    Evaluation.find()
    .exec (err,data)->
      if err
        res.json err
      else
        data.forEach (ev)->
          ev.deletedAt = null
          ev.save (err)->
            console.log err if err
    EvaluationSchedule.find()
    .exec (err,data)->
      if err
        res.json err
      else
        data.forEach (ev)->
          ev.deletedAt = null
          ev.save (err)->
            console.log err if err

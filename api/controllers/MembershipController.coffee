# api            = require "api-sdk"
# Membership     = new api.model "teammembership"
# Team           = new api.model "team"
# User           = new api.model "appuser"
# module.exports =
#   list: (req,res)->
#     udata   = UserData(req)
#     proceed = (data)->
#       res.json data

#     switch udata.active.roleId
#       when 32
#         # employee
#         filter =
#           appuserId: udata.appuser
#         Membership.find filter
#         .populate "appuserId"
#         .exec (err,data)->
#           if err
#             res.json err
#           else

#             if data.length
#               teams = data.map (d)->
#                 return d.teamId

#               teamFilter =
#                 id: teams

#               Team.find teamFilter
#               .populate "members"
#               .exec (err,fteams)->

#                 data.forEach (d,di)->

#                   ti = fteams.map (ft)->
#                     return ft.id
#                   .indexOf d.teamId

#                   l = fteams[ti].members.length

#                   fteams[ti].members = l
#                   d.team = fteams[ti]
#                   data[di].members = l

#                 res.json data
#             else
#               res.json []
#           return

#       when 26
#         # HR
#         filter =
#           company: udata.company
#           # deletedAt: null

#         Team.find filter
#         .exec (err,teams)->
#           if err
#             res.json err
#           else
#             if teams and teams.length
#               team_ids = teams.map (t)->
#                 return t.id

#               memberFilter =
#                 team: team_ids
#                 # deletedAt: null

#               Membership.find memberFilter
#               .populate "team"
#               .populate "user"
#               .exec (err,data)->
#                 if err
#                   res.json err
#                 else
#                   res.json data
#                 return
#             else
#               res.json []
#       when 28
#         # Spectator
#         SpectatorGroup.findOne spectator:udata.id
#         .exec (err,sg)->
#           if err
#             res.json err
#           else
#             if sg and sg.teams.length
#               memberFilter =
#                 team: sg.teams

#               Membership.find memberFilter
#               .populate "team"
#               .populate "user"
#               .exec (err,data)->
#                 if err
#                   res.json err
#                 else
#                   res.json data
#             else
#               res.json []

#   team: (req,res)->
#     filter =
#       teamId: req.param "id"
#       # deletedAt: null

#     Membership.find filter
#     .populate "appuserId"
#     .exec (err,members)->
#       if err
#         res.json err
#       else
#         res.json members
#       return
#     return
#   disconnect: (req,res)->
#     delete req.body.utf8

#     Membership.find req.body
#     .exec (err,data)->
#       if err
#         res.json err
#       else
#         if data.length > 0
#           Membership.delete data[0].id
#           .exec (err, result) ->
#             if err
#               res.json null
#             else
#               res.json result


#   create: (req,res)->
#     delete req.body.utf8
#     console.log req.body, typeof req.body.appuserId, typeof req.body.teamId,'create here'
#     Membership.create req.body
#     .exec (err,membership)->
#       console.log err, membership, 'HERHEHERHERHER'
#       if err
#         res.json error:err
#       else
#         User.find req.body.appuserId
#         .populate('profileId')
#         .exec (err, result) ->
#           if result.length > 0
#             result = result[0]

#           res.json result

#   clean: (req,res)->
#     Team.find()
#     .exec (err,teams)->
#       if err
#         res.json err
#       else
#         teamIds = teams.map (e)->
#           return e.id
#         filter =
#           team:
#             not: teamIds
#         Membership.destroy filter
#         .exec (err,mems)->
#           if err
#             res.json err
#           else
#             res.json mems

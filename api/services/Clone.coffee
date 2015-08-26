module.exports = 
  object: (obj)->
    copy = {}
    for attr of obj
      copy[attr] = obj[attr]  if obj.hasOwnProperty attr
    return copy

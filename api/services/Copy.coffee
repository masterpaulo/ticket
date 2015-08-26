module.exports = (obj)->
	copy = JSON.parse(JSON.stringify(obj))
	return copy
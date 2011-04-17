Binary = require './binary'

class JoinSource extends Binary
  constructor: (singleSource, joinop=[]) ->
    super()
    @right = [] # TODO Not sure if this is required but will fix issue with *on* test
    
exports = module.exports = JoinSource

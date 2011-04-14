Binary = require './binary'

class JoinSource extends Binary
  constructor: (singleSource, joinop=[]) ->
    super
    
exports = module.exports = JoinSource
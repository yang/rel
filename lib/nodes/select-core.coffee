Node = require './node'
JoinSource = require './join-source'

class SelectCore extends Node
  constructor: ->
    @source = new JoinSource(null)
    @top = null
    @projections = []
    @wheres = []
    @groups = []
    @having = null
    
  from: (value) ->
    if value
      @source.left = value
    else
      @source.left
    
  # TODO Not sure what this will do.
  initializeCopy: (other) ->
    super()
    @source = u(@source).clone() if @source
    @projections = u(@projections).clone()
    @wheres = u(@wheres).clone()
    @groups = u(@groups).clone()
    @having = u(@having).clone()
  
exports = module.exports = SelectCore

u = require 'underscore'
Node = require './node'

class DeleteStatement extends Node
  constructor: (@relation=null, @wheres=[]) ->
    super()
    @left = @relation
    @right = @wheres


exports = module.exports = DeleteStatement


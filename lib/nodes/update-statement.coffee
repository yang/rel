u = require 'underscore'
Node = require './node'

class UpdateStatement extends Node
  constructor: ->
    @relation = null
    @wheres = []
    @values = []
    @orders = []
    @limit = null
    @key = null

  initializeCopy: (other) ->
    super()
    @wheres = u(@wheres).clone()
    @values = u(@values).clone()


exports = module.exports = UpdateStatement

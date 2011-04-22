u = require 'underscore'
Node = require './node'

class InsertStatement extends Node
  constructor: ->
    @relation = null
    @columns = []
    @values = null

  initializeCopy: (other) ->
    super()
    @columns = u(@columns).clone()
    @values = u(@values).clone() if @values?

exports = module.exports = InsertStatement


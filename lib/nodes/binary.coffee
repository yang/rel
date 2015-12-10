Node = require './node'
_ = require 'underscore'

class Binary extends Node
  constructor: (@left, @right) ->
    Predications = require '../predications'
    _(@).extend(Predications)
    
exports = module.exports = Binary

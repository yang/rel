Node = require './node'

class Unary extends Node
  constructor: (@expr) ->
    @value = @expr

exports = module.exports = Unary

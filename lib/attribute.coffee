u = require 'underscore'

class Attribute
  constructor: (@relation, @name) ->
    Expressions = require './expressions'
    Predications = require './predications'
    u(@).extend Expressions
    u(@).extend Predications


exports = module.exports = Attribute

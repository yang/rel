u = require 'underscore'

class SqlLiteral
  constructor: (@value) ->
    Expressions = require('../expressions')
    Predications = require('../predications')
    u(@).extend(Expressions)
    u(@).extend(SqlLiteral)

  toString: ->
    @value

exports = module.exports = SqlLiteral

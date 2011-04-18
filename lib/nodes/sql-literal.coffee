u = require 'underscore'
Expressions = require('../expressions')
Predications = require('../predications')

class SqlLiteral
  constructor: (@value) ->
    u(@).extend(Expressions)
    u(@).extend(SqlLiteral)

  toString: ->
    @value

exports = module.exports = SqlLiteral

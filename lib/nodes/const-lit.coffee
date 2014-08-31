u = require 'underscore'
Unary = require './unary'
SqlLiteral = require './sql-literal'

class ConstLit extends Unary
  constructor: (args...) ->
    super(args...)
    Expressions = require '../expressions'
    Predications = require '../predications'
    u(@).extend Expressions
    u(@).extend Predications

exports = module.exports = ConstLit

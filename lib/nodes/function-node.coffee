u = require 'underscore'
Node = require './node'
SqlLiteral = require './sql-literal'

class FunctionNode extends Node
  constructor: (expr, aliaz=null) ->
    @expressions = expr
    @alias = aliaz
    @distinct = false
    Expressions = require '../expressions'
    Predications = require '../predications'
    u(@).extend Expressions
    u(@).extend Predications

  as: (aliaz) ->
    @alias = new SqlLiteral(aliaz)
    @


exports = module.exports = FunctionNode

u = require 'underscore'
Node = require './node'
SqlLiteral = require './sql-literal'
Expressions = require '../expressions'

class FunctionNode extends Node
  constructor: (expr, aliaz=null) ->
    @expressions = expr
    @alias = aliaz
    @distinct = false
    u(@).extend(Expressions)

  as: (aliaz) ->
    @alias = new SqlLiteral(aliaz)
    @


exports = module.exports = FunctionNode

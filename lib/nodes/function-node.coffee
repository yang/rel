u = require 'underscore'
Node = require './node'
SqlLiteral = require './sql-literal'
Expressions = require '../expressions'

class FunctionNode extends Node
  constructor: (expr, aliaz=null) ->
    @expressions = expr
    @alias = aliaz
    @distinct = false

  as: (aliaz) ->
    @alias = new SqlLiteral(aliaz)
    @

u(FunctionNode).extend(Expressions)

exports = module.exports = FunctionNode

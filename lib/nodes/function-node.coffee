u = require 'underscore'
Node = require './node'
SqlLiteral = require './sql-literal'

class FunctionNode extends Node
  constructor: (exprs, aliaz=null) ->
    @expressions = exprs
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

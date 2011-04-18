u = require 'underscore'
Visitors = require './visitors'
FactoryMethods = require './factory-methods'


class TreeManager extends FactoryMethods
  constructor: ->
    # TODO need to implement engines with a factory.
    @visitor = Visitors.visitor()
    @ast = null
    @ctx = null

  toDot: ->
    new Visitors.Dot().accept @ast

  toSql: ->
    @visitor.accept @ast

  initializeCopy: (other) ->
    super()
    @ast = u(@ast).clone()

  where: (expr) ->
    if TreeManager == expr.constructor
      expr = expr.ast
    @ctx.wheres.push expr
    @


exports = module.exports = TreeManager

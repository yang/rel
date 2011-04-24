u = require 'underscore'
FactoryMethods = require './factory-methods'


class TreeManager extends FactoryMethods
  constructor: ->
    # TODO need to implement engines with a factory.
    @visitor = @visitors().visitor()
    @ast = null
    @ctx = null

  visitors: ->
    require('./visitors')

  toDot: ->
    new @visitors().Dot().accept @ast

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

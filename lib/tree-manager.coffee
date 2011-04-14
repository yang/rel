u = require 'underscore'

class TreeManager
  constructor: ->
    # TODO need to implement engines with a factory.
    @visitor = Visitors.visitor_for null
    @ast = null
    @ctx = null

  toDot: ->
    new Visitors.Dot().accept @ast

  toSql: ->
    @visitor.accept @ast

  initializeCopy: (other) ->
    super
    @ast = u(@ast).clone()

  where: (expr) ->
    if @.class == expr
      expr = expr.ast
    @ctx.wheres.push expr
    @

exports = module.exports = TreeManager

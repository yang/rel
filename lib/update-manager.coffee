u = require 'underscore'
TreeManager = require './tree-manager'
UpdateStatement = require './nodes/update-statement'
Nodes = require './nodes/nodes'

class UpdateManager extends TreeManager
  constructor: ->
    super()
    @ast = new UpdateStatement()
    @ctx = @ast

  take: (limit) ->
    @ast.limit = new Nodes.Limit(limit) if limit?
    @

  key: (key) ->
    @ast.key = key

  order: (expr...) ->
    @ast.orders = expr
    @

  table: (table) ->
    @ast.relation = table
    @

  wheres: (expr...) ->
    @ast.wheres = expr

  where: (expr) ->
    @ast.wheres.push expr
    @

  set: (values) ->
    if values.constructor == String
      @ast.values = [values]
    else if values.constructor == Nodes.SqlLiteral
      @ast.values = [values]
    else
      @ast.values = values.map (val) =>
        column = val[0]
        value = val[1]
        new Nodes.Assignment(new Nodes.UnqualifiedColumn(column), value)
    @

exports = module.exports = UpdateManager

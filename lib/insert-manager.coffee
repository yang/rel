u = require 'underscore'
TreeManager = require './tree-manager'
InsertStatement = require './nodes/insert-statement'
Nodes = require './nodes/nodes'

class InsertManager extends TreeManager
  constructor: ->
    super()
    @ast = new InsertStatement()

  createValues: (values, columns) ->
    new Nodes.Values values, columns

  columns: ->
    @ast.columns

  values: (values) ->
    if values?
      @ast.values = values
    else
      @ast.values

  insert: (fields) ->
    return if u(fields).isEmpty()

    if fields.constructor == String
      @ast.values = new Nodes.SqlLiteral fields
    else
      @ast.relation ||= fields[0][0].relation

      values = []

      u(fields).each (field) =>
        column = field[0]
        value = field[1]
        @ast.columns.push column
        values.push value
      @ast.values = @createValues values, @ast.columns

  into: (table) ->
    @ast.relation = table
    @

exports = module.exports = InsertManager

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
    @ast.values = values

exports = module.exports = InsertManager

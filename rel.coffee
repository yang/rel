Nodes = require './lib/nodes/nodes'
Range = require './lib/range'
Table = require './lib/table'

Rel =
  VERSION: '0.0.1'

  sql: (rawSql) ->
    new Nodes.SqlLiteral rawSql

  star: ->
    @sql '*'

  range: (start, finish) ->
    new Range(start, finish)

  func: (name) -> (args...) =>
    new Nodes.FunctionNode(args, @sql(name))

  Table: Table


exports = module.exports = Rel

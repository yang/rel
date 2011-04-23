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

  Table: Table


exports = module.exports = Rel

Nodes = require './lib/nodes/nodes'
Range = require './lib/range'
Table = require './lib/table'
SelectManager = require './lib/select-manager'
InsertManager = require './lib/select-manager'
UpdateManager = require './lib/select-manager'
CaseBuilder = require './lib/nodes/case-builder'

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

  lit: (value) -> new Nodes.ConstLit(value)

  as: (a,b) -> new Nodes.As(a, new Nodes.UnqualifiedName(b))

  cast: (a,b) -> Rel.func('CAST')(Rel.as(a, b))

  Nodes: Nodes

  Table: Table

  table: (args...) -> new Table(args...)
  select: -> new SelectManager()
  insert: -> new InsertManager()
  update: -> new UpdateManager()
  case: (args...) -> new CaseBuilder(args...)

exports = module.exports = Rel

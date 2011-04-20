Dot = require './visitors/dot'
Postgresql = require './visitors/postgresql'
ToSql = require './visitors/to-sql'

Visitors = 
  Dot: Dot
  visitor: ->
    new Postgresql()
  JoinSql:
    visitRelNodesSelectCore: (o) ->
      (o.source.right.map (j) => @visit(j)).join ' '
  OrderClauses: class OrderClauses extends ToSql
    visitRelNodesSelectStatement: (o) ->
      o.orders.map (x) => @visit(x)

exports = module.exports = Visitors

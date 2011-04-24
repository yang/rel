Dot = require './visitors/dot'
Default = require './visitors/default'
ToSql = require './visitors/to-sql'

Visitors = 
  Dot: Dot
  visitor: ->
    # TODO figure out a factory way of returning the 
    new Default()
  JoinSql:
    visitRelNodesSelectCore: (o) ->
      (o.source.right.map (j) => @visit(j)).join ' '
  OrderClauses: class OrderClauses extends ToSql
    visitRelNodesSelectStatement: (o) ->
      o.orders.map (x) => @visit(x)
  WhereSql: class WhereSql extends ToSql
    visitRelNodesSelectCore: (o) ->
      "WHERE #{(o.wheres.map (x) => @visit x).join ' AND ' }"


exports = module.exports = Visitors

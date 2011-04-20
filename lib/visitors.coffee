Dot = require './visitors/dot'
Postgresql = require './visitors/postgresql'

Visitors = 
  Dot: Dot
  visitor: ->
    new Postgresql()
  JoinSql:
    visitRelNodesSelectCore: (o) ->
      (o.source.right.map (j) => @visit(j)).join ' '

exports = module.exports = Visitors

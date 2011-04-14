Nodes = require './nodes/nodes'

Expressions =
  count: (distinct=false) ->
    new Nodes.Count [@], distinct
    
  sum: ->
    new Nodes.Sum [@], new(Nodes.SqlLiteral('sum_id'))
    
  maximum: ->
    new Nodes.Max [@], new(Nodes.SqlLiteral('max_id'))
    
  minimum: ->
    new Nodes.Min [@], new(Nodes.SqlLiteral('min_id'))
    
  average: ->
    new Nodes.Avg [@], new(Nodes.SqlLiteral('avg_id'))
    
exports = module.exports = Expressions
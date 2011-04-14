Nodes = require './nodes'

class Node
  not: ->
    new Nodes.Not(@)
    
  or: (right) ->
    new Nodes.Grouping(new Nodes.Or(@, right))
    
  and: (right) ->
    new Nodes.And([@, right])
    
  # TODO Implement each and toSql
  
exports = module.exports = Node
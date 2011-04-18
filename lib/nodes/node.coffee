Nodes = require './nodes'
Visitors = require '../visitors'

class Node
  not: ->
    new Nodes.Not(@)
    
  or: (right) ->
    new Nodes.Grouping(new Nodes.Or(@, right))
    
  and: (right) ->
    new Nodes.And([@, right])
    
  # TODO Implement each and toSql
  toSql: ->
    Visitors.visitor().accept @
  
exports = module.exports = Node

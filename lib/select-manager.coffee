u = require 'underscore'
Nodes = require './nodes/nodes'

class SelectManager
  constructor: (table) ->
    @ast = new Nodes.SelectStatement()
    @ctx = u(@ast.cores).last()
    @from table
    
  project: (projections...) ->
    @ctx.projections.concat u(projections).map (x) ->
      if x.class == String then new SqlLiteral(x.toString()) else x
    @
    
  from: (table) ->
    new Nodes.SqlLiteral(table) if table.class == String
    
    switch table.class
      when Nodes.Join
        @ctx.source.right.push table
      else
        @ctx.source.left = table
    @
    
exports = module.exports = SelectManager

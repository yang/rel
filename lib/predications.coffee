u = require 'underscore'
Nodes = require './nodes/nodes'

Predications =
  as: (other) ->
    new Nodes.As @, new Nodes.SqlLiteral(other)
    
  notEq: (other) ->
    new Nodes.NotEqual @, other
  
  notEqAny: (others) ->
    @groupingAny 'not_eq', others
    
  notEqAll: (others) ->
    @groupingAll 'not_eq', others
    
  eq: (other) ->
    new Nodes.Equality @, others
    
  eqAny: (others) ->
    @groupingAny 'eq', others
    
  eqAll: (others) ->
    @groupingAll 'eq', others
    
  # TODO Ranges won't work here. Should support an array.
  in: (other) ->
    switch other.constructor
      when SelectManager
        new Nodes.In(@, other.ast)
      else
        new Nodes.In @, other
    
  inAny: (others) ->
    @groupingAny 'in', others
    
  inAll: (others) ->
    @groupingAll 'in', others
    
  # TODO Ranges won't work here. Should support an array.
  notIn: (other) ->
    switch other.constructor
      when SelectManager
        new Nodes.NotIn(@, other.ast)
      else
        new Nodes.NotIn(@, other)
  
  notInAny: (others) ->
    @groupingAny 'not_in', others
    
  notInAll: (others) ->
    @groupingAll 'not_in', others
    
  matches: (other) ->
    new Nodes.Matches @, other
    
  matchesAny: (others) ->
    @groupingAny 'matches', others
    
  matchesAll: (others) ->
    @groupingAll 'matches', others
    
  doesNotMatch: (other) ->
    new Nodes.DoesNotMatch @, other
    
  doesNotMatchAny: (others) ->
    @groupingAny 'does_not_match', others
    
  doesNotMatchAll: (others) ->
    @groupingAll 'does_not_match', others
    
  # Greater than
  gteq: (right) ->
    new Nodes.GreaterThanOrEqual @, right
    
  gteqAny: (others) ->
    @groupingAny 'gteq', others
    
  gteqAll: (others) ->
    @groupingAll 'gteq', others
    
  gt: (right) ->
    new Nodes.GreaterThan @, right
    
  gtAny: (others) ->
    @groupingAny 'gt', others
    
  gtAll: (others) ->
    @groupingAll 'gt', others
    
  # Less than
  lteq: (right) ->
    new Nodes.LessThanOrEqual @, right
    
  lteqAny: (others) ->
    @groupingAny 'lteq', others
    
  lteqAll: (others) ->
    @groupingAll 'lteq', others
    
  lt: (right) ->
    new Nodes.LessThan @, right
    
  ltAny: (others) ->
    @groupingAny 'lt', others
    
  ltAll: (others) ->
    @groupingAll 'lt', others
    
  asc: ->
    new Nodes.Ordering @, 'asc'
    
  desc: ->
    new Nodes.Ordering @, 'desc'
    
  groupingAny: (methodId, others) ->
    others = u(others).clone()
    first = others[methodId](others.shift())
    
    new Nodes.Grouping u(others).reduce first, (memo, expr) ->
      new Nodes.Or([memo, @[methodId](expr)])
    
  groupingAll: (methodId, others) ->
    others = u(others).clone()
    first = others[methodId](others.shift())
    
    new Nodes.Grouping u(others).reduce first, (memo, expr) ->
      new Nodes.And([memo, @[methodId](expr)])
      
exports = module.exports = Predications

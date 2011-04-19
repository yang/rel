u = require 'underscore'
SelectManager = require './select-manager'
Range = require './range'

Predications =
  nodes: ->
    require './nodes/nodes'

  as: (other) ->
    n = @nodes()
    lit = new n.SqlLiteral(other)
    new n.As @, lit
    
  notEq: (other) ->
    n = @nodes()
    new n.NotEqual @, other
  
  notEqAny: (others) ->
    @groupingAny 'not_eq', others
    
  notEqAll: (others) ->
    @groupingAll 'not_eq', others
    
  eq: (other) ->
    n = @nodes()
    new n.Equality @, other
    
  eqAny: (others) ->
    @groupingAny 'eq', others
    
  eqAll: (others) ->
    @groupingAll 'eq', others
    
  # TODO Ranges won't work here. Should support an array.
  in: (other) ->
    n = @nodes()
    switch other.constructor
      when SelectManager
        new n.In(@, other.ast)
      when Range
        new n.Between(@, new n.And([other.start, other.finish])) # Start and finish from range.
      else
        new n.In @, other
    
  inAny: (others) ->
    @groupingAny 'in', others
    
  inAll: (others) ->
    @groupingAll 'in', others
    
  # TODO Ranges won't work here. Should support an array.
  notIn: (other) ->
    n = @nodes()
    switch other.constructor
      when SelectManager
        new n.NotIn(@, other.ast)
      else
        new n.NotIn(@, other)
  
  notInAny: (others) ->
    @groupingAny 'not_in', others
    
  notInAll: (others) ->
    @groupingAll 'not_in', others
    
  matches: (other) ->
    n = @nodes()
    new n.Matches @, other
    
  matchesAny: (others) ->
    @groupingAny 'matches', others
    
  matchesAll: (others) ->
    @groupingAll 'matches', others
    
  doesNotMatch: (other) ->
    n = @nodes()
    new n.DoesNotMatch @, other
    
  doesNotMatchAny: (others) ->
    @groupingAny 'does_not_match', others
    
  doesNotMatchAll: (others) ->
    @groupingAll 'does_not_match', others
    
  # Greater than
  gteq: (right) ->
    n = @nodes()
    new n.GreaterThanOrEqual @, right
    
  gteqAny: (others) ->
    @groupingAny 'gteq', others
    
  gteqAll: (others) ->
    @groupingAll 'gteq', others
    
  gt: (right) ->
    n = @nodes()
    new n.GreaterThan @, right
    
  gtAny: (others) ->
    @groupingAny 'gt', others
    
  gtAll: (others) ->
    @groupingAll 'gt', others
    
  # Less than
  lteq: (right) ->
    n = @nodes()
    new n.LessThanOrEqual @, right
    
  lteqAny: (others) ->
    @groupingAny 'lteq', others
    
  lteqAll: (others) ->
    @groupingAll 'lteq', others
    
  lt: (right) ->
    n = @nodes().LessThan
    new n(@, right)
    
  ltAny: (others) ->
    @groupingAny 'lt', others
    
  ltAll: (others) ->
    @groupingAll 'lt', others
    
  asc: ->
    n = @nodes()
    new n.Ordering @, 'asc'
    
  desc: ->
    n = @nodes()
    new n.Ordering @, 'desc'
    
  groupingAny: (methodId, others) ->
    others = u(others).clone()
    first = others[methodId](others.shift())
    
    n = @nodes()
    new n.Grouping u(others).reduce first, (memo, expr) ->
      new n.Or([memo, @[methodId](expr)])
    
  groupingAll: (methodId, others) ->
    others = u(others).clone()
    first = others[methodId](others.shift())
    
    n = @nodes()
    new n.Grouping u(others).reduce first, (memo, expr) ->
      new n.And([memo, @[methodId](expr)])

exports = module.exports = Predications

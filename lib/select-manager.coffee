u = require 'underscore'
Nodes = require './nodes/nodes'
TreeManager = require './tree-manager'
Rel = require '../rel'

class SelectManager extends TreeManager
  constructor: (table) ->
    super()
    @ast = new Nodes.SelectStatement()
    @ctx = u(@ast.cores).last()
    @from table
    
  project: (projections...) ->
    @ctx.projections = @ctx.projections.concat projections.map (x) ->
      if x.constructor == String then new Nodes.SqlLiteral(x.toString()) else x

    @

  order: (expr...) ->
    @ast.orders = @ast.orders.concat expr.map (x) =>
      if x.constructor == String then new Nodes.SqlLiteral(x.toString()) else x
    @
    
  from: (table) ->
    table = new Nodes.SqlLiteral(table) if table? and table.constructor == String
    
    if table?
      switch table.constructor
        when Nodes.Join
          @ctx.source.right.push table
        else
          @ctx.source.left = table
    else
      @ctx.source.left = null
    @

  group: (columns...) ->
    for column in columns
      c = if column.constructor == String
        new Nodes.SqlLiteral(column.toString())
      else
        column

      @ctx.groups.push(new Nodes.Group(c))
    @

  as: (other) ->
    @createTableAlias @grouping(@ast), new Nodes.SqlLiteral(other)

  having: (exprs...) ->
    @ctx.having = new Nodes.Having(@collapse(exprs, @ctx.having))
    @

  collapse: (exprs, existing=null) ->
    exprs = exprs.unshift(existing.expr) if existing?
    exprs = u(exprs).compact().map (expr) =>
      if expr.constructor == String
        Rel.sql expr
      else
        expr

    if exprs.length == 1
      exprs[0]
    else
      @createAnd exprs

  join: (relation, klass=Nodes.InnerJoin) ->
    return @ unless relation?

    switch relation.constructor
      when String, Nodes.SqlLiteral
        klass = Nodes.StringJoin

    @ctx.source.right.push @createJoin(relation, null, klass)
    @

  on: (exprs...) ->
    u(@ctx.source.right).last().right = new Nodes.On(@collapse(exprs))
    @

  skip: (amount) ->
    if amount?
      @ast.offset = new Nodes.Offset(amount)
    else
      @ast.offset = null

    @

  offset: (amount) ->
    @skip amount

  exists: ->
    new Nodes.Exists(@ast)
    
  capitalize: (string) ->
    op = string.toString()
    op[0].toUpperCase() + op.slice(1, op.length)

  union: (operation, other=null) ->
    nodeClass = if other?
      Nodes["Union#{@capitalize(operation)}"] # TODO capitalize the operation.
    else
      other = operation
      Nodes.Union

    new nodeClass @.ast, other.ast

  except: (other) ->
    new Nodes.Except(@ast, other.ast)
  minus: (other) ->
    @except other

  intersect: (other) ->
    new Nodes.Intersect @ast, other.ast

  with: (subqueries...) ->
    nodeClass = if u(subqueries).first().constructor == String
      Nodes["With#{@capitalize(subqueries.shift())}"]
    else
      Nodes.With

    @ast.with = new nodeClass(u(subqueries).flatten())

    @



exports = module.exports = SelectManager

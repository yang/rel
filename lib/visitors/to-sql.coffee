u = require 'underscore'
Visitor = require 'visitor'
Nodes = require '../nodes/nodes'

class ToSql < Visitor
  constructor: ->
    @connection = nil
    @pool = nil
    @last_column = nil
    @quoted_tables = {}
    @quoted_columns = {}

  accept: (object) ->
    @last_column = nil
    @pool = null # TODO need to build out engines.
    @pool.withConnection (conn) =>
      @connection = conn
      super
  
  visitRelNodesDeleteStatement: (o) ->
    u([
      "DELETE FROM #{@visit o.relation}", 
      ("WHERE #{(u(o.wheres).map (x) => @visit(x)).join 'AND '}" unless u(o.wheres).isEmpty())
    ]).compact().join(' ')

  buildSubSelect: (key, o) ->
    stmt = new Nodes.SelectStatement
    core = u(stmt.cores).first()
    core.froms = o.relation
    core.wheres = o.wheres
    core.projections = [key]
    stmt.limit = o.limit
    stmt.orders = o.orders
    stmt

  visitRelNodesUpdateStatement: (o) ->
    wheres = if u(o.orders).isEmpty() and !o.limit?
      o.wheres
    else
      key = o.key
      [new Nodes.In(key, [@buildSubselect(key, o)])]
    u([
      "UPDATE #{@visit o.relation}",
      ("SET #{(o.values.map (value) => @visit value).join ', '}" unless u(o.values).isEmpty()),
      ("WHERE #{(wheres.map (x) => @visit x).join ' AND '}" unless u(u.wheres).isEmpty())
    ]).compact().join(' ')

  visitRelNodesInsertStatement: (o) ->
    u([
      "INSERT INTO #{@visit o.relation}",
      ("(#{(u(o.columns).map (x) => @quoteColumnName(x)).join ', '})" unless u(o.columns).isEmpty()),
      (@visit o.values if o.values?)
    ]).compact().join(' ')

  visitArelNodesExist: (o) ->
    "EXISTS (#{@visit o.expressions})#{if o.alias then " AS #{visit o.alias}" else ''}"

  # TODO implement table exists
  tableExists: (name) ->
    false

  visitRelNodesSelectStatement: (o) ->
    u([
      (@visit(o.with) if o.with?),
      (u(o.cores.map ((x) =>  visitRelNodesSelectCore(x)).join),
      ("ORDER BY #{o.orders.map ((x) => @visit).join(', ')}" unless u(o.orders).isEmpty()),
      (@visit(o.limit) if o.limit?),
      (@visit(o.offset) if o.offset?),
      (@visit(o.lock) if o.lock?),
    ]).compact().join()

  visitRelNodesSelectCore: (o) ->
    u([
      "SELECT",
      (@visit(o.top) if o.top?),
      ("#{u(o.projections.map ((x) => @visit(x)).join ', '}"),
      (visit(o.source)),
      ("WHERE #{u(o.wheres).map ((x) => @visit(x)).join ' AND ' }" unless u(o.wheres).isEmpty()),
      ("GROUP BY #{u(o.groups).map ((x) => @visit(x)).join ' AND ' }" unless u(o.groups).isEmpty()),
      (@visit(o.having) if o.having?)
    ]).compact().join()



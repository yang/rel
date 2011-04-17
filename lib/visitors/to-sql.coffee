u = require 'underscore'
Visitor = require './visitor'
Nodes = require '../nodes/nodes'

class ToSql extends Visitor
  constructor: ->
    @connection = null
    @pool = null
    @lastColumn = null
    @quotedTables = {}
    @quotedColumns = {}

  accept: (object) ->
    @last_column = null
    @pool = null # TODO need to build out engines.
    if @pool?
      @pool.withConnection (conn) =>
        @connection = conn
    super object
  
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

  visitRelNodesExist: (o) ->
    "EXISTS (#{@visit o.expressions})#{if o.alias then " AS #{visit o.alias}" else ''}"

  # TODO implement table exists
  tableExists: (name) ->
    false

  visitRelNodesSelectStatement: (o) ->
    u([
      (@visit(o.with) if o.with?),
      ((o.cores.map (x) => @visitRelNodesSelectCore(x)).join()),
      ("ORDER BY #{(o.orders.map (x) => @visit(x)).join(', ')}" unless u(o.orders).isEmpty()),
      (@visit(o.limit) if o.limit?),
      (@visit(o.offset) if o.offset?),
      (@visit(o.lock) if o.lock?)
    ]).compact().join(' ')

  visitRelNodesSelectCore: (o) ->
    u([
      "SELECT",
      (@visit(o.top) if o.top?),
      ("#{(o.projections.map (x) => @visit(x)).join(', ')}"),
      (@visit(o.source)),
      ("WHERE #{(o.wheres.map (x) => @visit(x)).join ' AND ' }" unless u(o.wheres).isEmpty()),
      ("GROUP BY #{(o.groups.map (x) => @visit(x)).join ' AND ' }" unless u(o.groups).isEmpty()),
      (@visit(o.having) if o.having?)
    ]).compact().join(' ')

  visitRelNodesJoinSource: (o) ->
    return unless o.left? || !u(o.right).isEmpty()

    u([
      "FROM",
      (@visit(o.left) if o.left?),
      ((o.right.map (j) => @visit(j)).join(' ') if o.right?)
    ]).compact().join ' '

  visitRelNodesTable: (o) ->
    if o.tableAlias?
      "#{@quoteTableName o.name} #{quoteTableName o.tableAlias}"
    else
      @quoteTableName o.name

  quoteTableName: (name) ->
    @quotedTables[name] ||= if Nodes.SqlLiteral == name.constructor then name else "\"#{name}\""

  quoteColumnName: (name) ->
    @quotedColumns[name] ||= if Nodes.SqlLiteral == name.constructor then name else "\"#{name}\""

  visitRelNodesArray: (o) ->
    if u(o).empty? then 'NULL' else (o.map (x) => @visit(x)).join(', ')

  literal: (o) ->
    o

  visitRelNodesSqlLiteral: (o) -> @literal(o)

  visitRelNodesGroup: (o) ->
    @visit o.expr

  visitRelNodesAttribute: (o) ->
    @lastColumn = @columnFor o
    joinName = o.relation.tableAlias || o.relation.name
    "#{@quoteTableName(joinName)}.#{@quoteColumnName(o.name)}"

  visitRelNodesAttrInteger: (o) -> @visitRelNodesAttribute(o)
  visitRelNodesAttrFloat: (o) -> @visitRelNodesAttribute(o)
  visitRelNodesAttrString: (o) -> @visitRelNodesAttribute(o)
  visitRelNodesAttrTime: (o) -> @visitRelNodesAttribute(o)
  visitRelNodesAttrBoolean: (o) -> @visitRelNodesAttribute(o)

  quoted: (o) ->
    @quote(o, @last_column)

  visitRelNodesString: (o) -> @quoted(o)
  visitRelNodesDate: (o) -> @quoted(o)

  visitRelNodesNumber: (o) -> @literal(o)

  quote: (value, column=null) ->
    "\"#{value}\""


  # TODO this is silly because we aren't checking against the connection.
  columnFor: (attr) ->
    attr.name.toString()

  visitRelNodesHaving: (o) ->
    "HAVING #{@visit o.expr}"

  visitRelNodesAnd: (o) ->
    (o.children.map (x) =>
      @visit x
    ).join ' AND '

  visitRelNodesInnerJoin: (o) ->
    "INNER JOIN #{@visit o.left} #{@visit o.right if o.right? and u(o.right).any()}"

  visitRelNodesOn: (o) ->
    "ON #{@visit o.expr}"

  visitRelNodesTableAlias: (o) ->
    "#{@visit o.relation} #{@quoteTableName o.name}"

  visitRelNodesOffset: (o) ->
    "OFFSET #{@visit o.expr}"




exports = module.exports = ToSql

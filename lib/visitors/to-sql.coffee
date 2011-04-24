u = require 'underscore'
Visitor = require './visitor'
Nodes = require '../nodes/nodes'
SqlLiteral = require '../nodes/sql-literal'
Attributes = require '../attributes'
require 'date-utils'

class ToSql extends Visitor
  constructor: ->
    @connection = null
    @pool = null
    @lastColumn = null

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
      ("WHERE #{(wheres.map (x) => @visit x).join ' AND '}" unless u(o.wheres).isEmpty())
    ]).compact().join(' ')

  buildSubselect: (key, o) ->
    stmt = new Nodes.SelectStatement()
    core = stmt.cores[0]
    core.froms = o.relation
    core.wheres = o.wheres
    core.projections = [key]
    stmt.limit = o.limit
    stmt.orders = o.orders
    stmt

  visitRelNodesAssignment: (o) ->
    right = @quote(o.right, @columnFor(o.left))
    "#{@visit o.left} = #{right}"

  visitRelNodesUnqualifiedColumn: (o) ->
    @quoteColumnName o.name() # TODO This probably shouldn't be a function.

  visitRelNodesInsertStatement: (o) ->
    u([
      "INSERT INTO #{if o.relation? then @visit o.relation else 'NULL'}",
      ("(#{(u(o.columns).map (x) => @quoteColumnName(x)).join ', '})" unless u(o.columns).isEmpty()),
      (@visit o.values if o.values?)
    ]).compact().join(' ')

  visitRelNodesValues: (o) ->
    "VALUES (#{(u(o.expressions()).map (expr) =>
      if expr == null
        @quote expr, null
      else if expr.constructor == SqlLiteral
        @visitRelNodesSqlLiteral expr
      else
        @quote(expr, null)
    ).join ', '})"


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
      ("GROUP BY #{(o.groups.map (x) => @visit(x)).join ', ' }" unless u(o.groups).isEmpty()),
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
    if Nodes.SqlLiteral == name.constructor then name else "\"#{name}\""

  quoteColumnName: (name) ->
    if Nodes.SqlLiteral == name.constructor 
      name
    else if Attributes.Attribute == name.constructor
      @quote name.name
    else
      "\"#{name}\""

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
    if value == null
      'NULL'
    else if value.constructor == Boolean
      if value == true then "'t'" else "'f'"
    else if value.constructor == Date
      value.toDBString()
    else if value.constructor == Number
      value
    else
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

  visitRelNodesOr: (o) ->
    "#{@visit o.left} OR #{@visit o.right}"

  visitRelNodesInnerJoin: (o) ->
    "INNER JOIN #{@visit o.left} #{@visit o.right if o.right? and u(o.right).any()}"

  visitRelNodesOn: (o) ->
    "ON #{@visit o.expr}"

  visitRelNodesTableAlias: (o) ->
    "#{@visit o.relation} #{@quoteTableName o.name}"

  visitRelNodesOffset: (o) ->
    "OFFSET #{@visit o.expr}"

  visitRelNodesExists: (o) ->
    e = if o.alias then " AS #{@visit o.alias}" else ''
    "EXISTS (#{@visit o.expressions})#{e}"

  visitRelNodesUnion: (o) ->
    "( #{@visit o.left} UNION #{@visit o.right} )"

  visitRelNodesLessThan: (o) ->
    "#{@visit o.left} < #{@visit o.right}"

  visitRelNodesGreaterThan: (o) ->
    "#{@visit o.left} > #{@visit o.right}"

  visitRelNodesUnionAll: (o) ->
    "( #{@visit o.left} UNION ALL #{@visit o.right} )"

  visitRelNodesExcept: (o) ->
    "( #{@visit o.left} EXCEPT #{@visit o.right} )"

  visitRelNodesIn: (o) ->
    "#{@visit o.left} IN (#{@visit o.right})"

  visitRelNodesBetween: (o) ->
    "#{@visit o.left} BETWEEN (#{@visit o.right})"

  visitRelNodesIntersect: (o) ->
    "( #{@visit o.left} INTERSECT #{@visit o.right} )"

  visitRelNodesWith: (o) ->
    "WITH #{(o.children.map (x) => @visit x).join(', ')}"

  visitRelNodesWithRecursive: (o) ->
    "WITH RECURSIVE #{(o.children.map (x) => @visit x).join(', ')}"

  visitRelNodesAs: (o) ->
    "#{@visit o.left} AS #{@visit o.right}"

  visitRelNodesEquality: (o) ->
    right = o.right

    if right?
      "#{@visit o.left} = #{@visit right}"
    else
      "#{@visit o.left} IS NULL"

  visitRelNodesLock: (o) ->

  visitRelNodesOuterJoin: (o) ->
    "LEFT OUTER JOIN #{@visit o.left} #{@visit o.right}"

  visitRelNodesStringJoin: (o) ->
    @visit o.left

  visitRelNodesTop: (o) ->
    ""

  visitRelNodesLimit: (o) ->
    "LIMIT #{@visit o.expr}"

  visitRelNodesGrouping: (o) ->
    "(#{@visit o.expr})"





exports = module.exports = ToSql

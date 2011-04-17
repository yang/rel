u = require 'underscore'
Visitor = require './visitor'

class Node
  constructor: (@name, @id, @fields=[]) ->

class Edge
  constructor: (@name, @from, @to) ->

class Dot extends Visitor
  constructor: ->
    @nodes = []
    @edges = []
    @nodeStack = []
    @edgeStack = []
    @seen = {}

  accept: (object) ->
    super(object)
    @toDot()

  visitRelNodesOrdering: (o) ->
    @visitEdge o, 'expr'
    @visitEdge o, 'direction'

  visitRelNodesTableAlias: (o) ->
    @visitEdge o, 'name'
    @visitEdge o, 'relation'

  visitRelNodesCount: (o) ->
    @visitEdge o, 'expressions'
    @visitEdge o, 'distinct'

  visitRelNodesValues: (o) ->
    @visitEdge o, 'expressions'

  visitRelNodesStringJoin: (o) ->
    @visitEdge o, 'left'

  visitRelNodesInnerJoin: (o) ->
    @visitEdge o, 'left'
    @visitEdge o, 'right'

  visitRelNodesOuterJoin: (o) -> @visitRelNodesInnerJoin(o) # Alias

  visitRelNodesDeleteStatement: (o) ->
    @visitEdge o, 'relation'
    @visitEdge o, 'wheres'

  unary: (o) ->
    @visitEdge o, 'expr'

  visitRelNodesGroup: (o) -> @unary(o)
  visitRelNodesGrouping: (o) -> @unary(o)
  visitRelNodesHaving: (o) -> @unary(o)
  visitRelNodesLimit: (o) -> @unary(o)
  visitRelNodesNot: (o) -> @unary(o)
  visitRelNodesOffset: (o) -> @unary(o)
  visitRelNodesOn: (o) -> @unary(o)
  visitRelNodesTop: (o) -> @unary(o)
  visitRelNodesUnqualifiedColumn: (o) -> @unary(o)

  func: (o) ->
    @visitEdge o, 'expressions'
    @visitEdge o, 'distinct'
    @visitEdge o, 'alias'

  visitRelNodesExists: (o) -> @func(o)
  visitRelNodesMin: (o) -> @func(o)
  visitRelNodesMax: (o) -> @func(o)
  visitRelNodesAvg: (o) -> @func(o)
  visitRelNodesSum: (o) -> @func(o)

  visitRelNamedFunction: (o) ->
    @visitEdge o, 'name'
    @visitEdge o, 'expressions'
    @visitEdge o, 'distinct'
    @visitEdge o, 'alias'

  visitRelNodesInsertStatement: (o) ->
    @visitEdge o, 'relation'
    @visitEdge o, 'columns'
    @visitEdge o, 'values'

  visitRelNodesSelectCore: (o) ->
    @visitEdge o, 'source'
    @visitEdge o, 'projections'
    @visitEdge o, 'wheres'

  visitRelNodesSelectStatement: (o) ->
    @visitEdge o, 'cores'
    @visitEdge o, 'limit'
    @visitEdge o, 'orders'
    @visitEdge o, 'offset'

  visitRelNodesUpdateStatement: (o) ->
    @visitEdge o, 'relation'
    @visitEdge o, 'wheres'
    @visitEdge o, 'values'

  visitRelTable: (o) ->
    @visitEdge o, 'name'

  visitRelAttribute: (o) ->
    @visitEdge o, 'relation'
    @visitEdge o, 'name'

  visitRelAttributesInteger: (o) -> @visitRelAttribute(o)
  visitRelAttributesFloat: (o) -> @visitRelAttribute(o)
  visitRelAttributesString: (o) -> @visitRelAttribute(o)
  visitRelAttributesTime: (o) -> @visitRelAttribute(o)
  visitRelAttributesBoolean: (o) -> @visitRelAttribute(o)
  visitRelAttributesAttribute: (o) -> @visitRelAttribute(o)
  
  nary: (o) ->
    u(o.children).each (x, i) =>
      @edge i, (x) =>
        @visit x

  visitRelNodesAnd: (o) -> @nary(o)

  binary: (o) ->
    @visitEdge o, 'left'
    @visitEdge o, 'right'

  visitRelNodesAs: (o) -> @binary(o)
  visitRelNodesAssignment: (o) -> @binary(o)
  visitRelNodesBetween: (o) -> @binary(o)
  visitRelNodesDoesNotMatch: (o) -> @binary(o)
  visitRelNodesEquality: (o) -> @binary(o)
  visitRelNodesGreaterThan: (o) -> @binary(o)
  visitRelNodesGreaterThanOrEqual: (o) -> @binary(o)
  visitRelNodesIn: (o) -> @binary(o)
  visitRelNodesJoinSource: (o) -> @binary(o)
  visitRelNodesLessThan: (o) -> @binary(o)
  visitRelNodesLessThanOrEqual: (o) -> @binary(o)
  visitRelNodesMatches: (o) -> @binary(o)
  visitRelNodesNotEqual: (o) -> @binary(o)
  visitRelNodesNotIn: (o) -> @binary(o)
  visitRelNodesOr: (o) -> @binary(o)

  visitString: (o) ->
    u(@nodeStack).last().fields.push o

  visitTime: (o) -> visitString(o)
  visitDate: (o) -> visitString(o)
  visitDateTime: (o) -> visitString(o)
  visitNullClass: (o) -> visitString(o)
  visitTrueClass: (o) -> visitString(o)
  visitFalseClass: (o) -> visitString(o)
  visitRelSqlLiteral: (o) -> visitString(o)
  visitInteger: (o) -> visitString(o)
  visitFloat: (o) -> visitString(o)
  visitRelNodesSqlLiteral: (o) -> visitString(o)

  visitHash: (o) ->
    u(o).each (value, key, index) =>
      @edge {key: value}, =>
        @visit {key: value}

  visitArray: (o) ->
    u(o).each (x, i) =>
      @edge i, (x) =>
        visit x

  visitEdge: (o, method) ->
    @edge method, =>
      @visit o[method]

  visit: (o) ->
    if node = @seen[o.object]
      @edgeStack.last.to = node
      return

    node = new Node(o.constructor.name, o)
    @seen[node.id] = node
    @nodes.push node

    withNode (node) =>
      @super(o)

  edge: (name, callback) ->
    edge = new Edge(name, u(@nodeStack).last())
    @edgeStack.push edge
    @edges.push edge
    callback()
    @edgeStack.pop()

  withNode: (node, callback) ->
    if edge = u(@edgeStack).last()
      edge.to = node

    @nodeStack.push node
    callback()
    @nodeStack.pop()

  quote: (string) ->
    string.toString().replace /\"/g, "\""

  toDot: ->
    "digraph \"ARel\" {\nnode [width=0.375,height=0.25,shape=record];\n" +
    (u(@nodes).map (node) =>
      label = "<f0>#{node.name}"

      u(node.fields).each (field, i) =>
        label.push "|<f#{i + 1}>#{@quote field}"

      "#{node.id} [label=\"#{label}\"];"
    ).join("\n") + "\n" + u(@edges).map ((edge) ->
      "#{edge.from.id} -> #{edge.to.id} [label=\"#{edge.name}\"];"
    ).join("\n") + "\n}"

exports = module.exports = Dot

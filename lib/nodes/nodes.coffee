Binary = require './binary'
SelectStatement = require('./select-statement')
SqlLiteral = require('./sql-literal')
SelectCore = require('./select-core')
Unary = require './unary'
TableAlias = require './table-alias'
And = require './and'
FunctionNode = require './function-node'

Nodes = 
  SelectStatement: SelectStatement
  SqlLiteral: SqlLiteral
  SelectCore: SelectCore
  Binary: Binary
  TableAlias: TableAlias
  And: And
  Join: class Join extends Binary
  InnerJoin: class InnerJoin extends Join
  OuterJoin: class OuterJoin extends Join
  StringJoin: class StringJoin extends Join
    constructor: (left, right=null) ->
      super left, right
  TableAlias: class TableAlias extends Binary
    constructor: (@left, @right) ->
      super(@left, @right)
      @name = @right
      @relation = @left
      @tableAlias = @name
      @tableName = @relation.name
  FunctionNode: FunctionNode
  Sum: class Sum extends FunctionNode
  Exists: class Exists extends FunctionNode
  Max: class Max extends FunctionNode
  Min: class Min extends FunctionNode
  Avg: class Avg extends FunctionNode
  As: class As extends Binary
  Assignment: class Assignment extends Binary
  Between: class Between extends Binary
  DoesNotMatch: class DoesNotMatch extends Binary
  GreaterThan: class GreaterThan extends Binary
  GreaterThanOrEqual: class GreaterThanOrEqual extends Binary
  Join: class Join extends Binary
  LessThan: class LessThan extends Binary
  LessThanOrEqual: class LessThanOrEqual extends Binary
  Matches: class Matches extends Binary
  NotEqual: class NotEqual extends Binary
  NotIn: class NotIn extends Binary
  Or: class Or extends Binary
  Union: class Union extends Binary
  UnionAll: class UnionAll extends Binary
  Intersect: class Intersect extends Binary
  Except: class Except extends Binary
  Bin: class Bin extends Unary
  Group: class Group extends Unary
  Grouping: class Grouping extends Unary
  Having: class Having extends Unary
  Limit: class Limit extends Unary
  Not: class Not extends Unary
  Offset: class Offset extends Unary
  On: class On extends Unary
  Top: class Top extends Unary
  Lock: class Lock extends Unary
  Equality: class Equality extends Binary
    constructor: (@left, @right) ->
      super @left, @right
      @operator = '=='
      @operand1 = @left
      @operand2 = @right
  In: class In extends Equality
  
exports = module.exports = Nodes

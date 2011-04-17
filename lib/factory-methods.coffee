Nodes = require './nodes/nodes'

class FactoryMethods
  createTableAlias: (relation, name) ->
    new Nodes.TableAlias(relation, name)

  createJoin: (to, constraint=null, klass=Nodes.InnerJoin) ->
    new klass to, constraint

  createStringJoin: (to) ->
    @createJoin to, null, Nodes.StringJoin

  createAnd: (clauses) ->
    new Nodes.And clauses

  createOn: (expr) ->
    new Nodes.On expr

  grouping: (expr) ->
    new Nodes.Grouping expr

exports = module.exports = FactoryMethods

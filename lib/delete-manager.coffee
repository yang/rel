u = require 'underscore'
TreeManager = require './tree-manager'
DeleteStatement = require './nodes/delete-statement'
Nodes = require './nodes/nodes'

class DeleteManager extends TreeManager
  constructor: ->
    super()
    @ast = new DeleteStatement()
    @ctx = @ast

  from: (relation) ->
    @ast.relation = relation
    @

  wheres: (list) ->
    @ast.wheres = list


exports = module.exports = DeleteManager


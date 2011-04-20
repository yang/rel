u = require 'underscore'
SelectManager = require './select-manager'
Attributes = require './attributes'
Nodes = require './nodes/nodes'

class Table
  constructor: (@name) ->
    @columns = null
    @aliases = []
    @tableAlias = null

    
  from: (table) ->
    new SelectManager(table)
    
  project: (things...) ->
    @from(@).project things

  attribute: (name) ->
    new Attributes.Attribute(@, name)

  alias: (name) ->
    name = "#{@name}_2" unless name?

    u(new Nodes.TableAlias(@, name)).tap (node) =>
      @aliases.push node

  column: (name) ->
    new Attributes.Attribute @, name

  join: (relation, klass=Nodes.InnerJoin) ->
    return @from(@) unless relation?

    switch relation.constructor
      when String, Nodes.SqlLiteral
        klass = Nodes.StringJoin
    @from(@).join(relation, klass)

module.exports = Table

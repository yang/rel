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

module.exports = Table

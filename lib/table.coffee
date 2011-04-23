u = require 'underscore'
SelectManager = require './select-manager'
InsertManager = require './insert-manager'
UpdateManager = require './update-manager'
DeleteManager = require './delete-manager'
Attributes = require './attributes'
Nodes = require './nodes/nodes'
FactoryMethods = require './factory-methods'
Crud = require './crud'

class Table
  # TODO I think table alias does nothing.
  constructor: (@name, opts={}) ->
    @columns = null
    @aliases = []
    @tableAlias = null
    u(@).extend(new FactoryMethods()) # TODO not sure about this.
    u(@).extend(new Crud())
    @tableAlias = opts['as'] if opts['as']?

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

  insertManager: ->
    new InsertManager()

  skip: (amount) ->
    @from(@).skip amount

  selectManager: ->
    new SelectManager()

  having: (expr) ->
    @from(@).having expr

  group: (columns...) ->
    @from(@).group columns

  order: (expr...) ->
    @from(@).order expr

  take: (amount) ->
    @from(@).take amount

  where: (condition) ->
    @from(@).where condition



module.exports = Table

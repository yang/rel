class TableAlias
  constructor: (@left, @right) ->

  name: ->
    @right

  relation: ->
    @left

  tableAlias: ->
    @relation().name

  tableName: ->
    @relation().name

exports = module.exports = TableAlias

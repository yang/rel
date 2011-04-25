InsertManager = require './insert-manager'
UpdateManager = require './update-manager'
SqlLiteral = require './nodes/sql-literal'

class Crud
  compileInsert: (values) ->
    im = @createInsert()
    im.insert values
    im

  createInsert: ->
    new InsertManager()

  compileDelete: ->
    dm = new DeleteManager()
    dm.wheres @ctx.wheres
    dm.from @ctx.froms
    dm

  compileUpdate: (values) ->
    um = new UpdateManager()

    relation = if values.constructor == SqlLiteral
      @ctx.from
    else
      values[0][0].relation

    um.table relation
    um.set values
    um.take @ast.limit.expr if @ast.limit?
    um.order @ast.orders
    um.wheres = @ctx.wheres
    um

exports = module.exports = Crud

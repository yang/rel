InsertManager = require './insert-manager'

class Crud
  compileInsert: (values) ->
    im = @createInsert()
    im.insert values
    im

  createInsert: ->
    new InsertManager()

  compileDelete: ->
    # dm = new DeleteManager()
    # dm.wheres @ctx.wheres
    # dm.from @ctx.froms
    # dm

exports = module.exports = Crud

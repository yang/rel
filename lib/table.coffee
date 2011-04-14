SelectManager = require './select-manager'

class Table
  constructor: (@name) ->
    
  from: (table) ->
    new SelectManager(table)
    
  project: (things...) ->
    @from(@).project things

module.exports = Table

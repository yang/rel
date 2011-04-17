Dot = require './visitors/dot'
Postgresql = require './visitors/postgresql'

Visitors = 
  Dot: Dot
  visitor: ->
    new Postgresql()
    

exports = module.exports = Visitors

require './visitors/dot'

Visitors = 
  Dot: Dot
  visitorFor: ->
    require './visitors/postgresql'

exports = module.exports = Visitors

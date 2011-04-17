class Visitor
  accept: (object) ->
    @visit object

  visit: (object) ->
    @["visitRelNodes#{object.constructor.name}"](object)

exports = module.exports = Visitor

class Visitor
  accept: (object) ->
    @visit object

  visit: (object) ->
    type = object?.constructor.name ? 'Null'
    @["visitRelNodes#{type}"](object)

exports = module.exports = Visitor

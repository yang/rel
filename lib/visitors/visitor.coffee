class Visitor
  accept: (object) ->
    @visit object

  visit: (object) ->
    @["visit#{object.class.toString()}"]()

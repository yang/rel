class Visitor
  accept: (object) ->
    @visit object

  visit: (object) ->
    # TODO Need to make this actually work.
    console.log 'hit visit'
    null

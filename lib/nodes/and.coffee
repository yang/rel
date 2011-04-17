Node = require './node'

class And extends Node
  constructor: (children, right=null) ->
    unless Array == children.constructor
      children = [children, right]

    @children = children

  left: ->
    @children.first

  right: ->
    @children[1]


exports = module.exports = And
  

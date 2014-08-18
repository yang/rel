u = require 'underscore'
Node = require './node'

class CaseBuilder
  constructor: (@_base) ->
    @_cases = []
    @_else = undefined
  when: (cond, res) ->
    @_cases.push([cond, res])
    @
  else: (res) ->
    @_else = res
    @
  end: -> new Case(@_base, @_cases, @_else)

class Case extends Node
  constructor: (@_base, @_cases, @_else) ->
    u(@).extend require '../expressions'
    u(@).extend require '../predications'

exports = module.exports = CaseBuilder

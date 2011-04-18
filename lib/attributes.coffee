u = require 'underscore'
# TODO Implement math

class Attribute
  constructor: (@relation, @name) ->
    Expressions = require './expressions'
    Predications = require './predications'
    u(@).extend Expressions
    u(@).extend Predications

Attributes = 
  Attribute: Attribute
  AttrString: class AttrString extends Attribute
  AttrTime: class AttrTime extends Attribute
  AttrBoolean: class AttrBoolean extends Attribute
  AttrDecimal: class AttrDecimal extends Attribute
  AttrFloat: class AttrFloat extends Attribute
  AttrInteger: class AttrInteger extends Attribute
  AttrUndefined: class AttrUndefined extends Attribute

exports = module.exports = Attributes

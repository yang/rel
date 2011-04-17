u = require 'underscore'
Expressions = require './expressions'
Predications = require './predications'
# TODO Implement math

class Attribute
  constructor: (@relation, @name) ->

u(Attribute).extend(Expressions)
u(Attribute).extend(Predications)



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

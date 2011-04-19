u = require 'underscore'
Attribute = require './attribute'
# TODO Implement math


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

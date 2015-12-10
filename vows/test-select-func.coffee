Rel = require '../rel'
vows = require 'vows'
assert = require 'assert'

tests = vows.describe('more querying').addBatch(
  'A sum function':
    topic: -> Rel.func('sum')
    'works': (sum) ->
      user = new Rel.Table 'user'
      q = user.where(sum(sum(user.column('age')).eq(1)))
      assert.equal q.toSql(), 'SELECT FROM "user" WHERE sum(sum("user"."age") = 1)'
  'A binary function':
    topic: -> Rel.func('coalesce')
    'works': (coalesce) ->
      user = new Rel.Table 'user'
      q = user.where(coalesce(user.column('age'), null).eq(1))
      assert.equal q.toSql(), 'SELECT FROM "user" WHERE coalesce("user"."age",NULL) = 1'
)

tests.export module

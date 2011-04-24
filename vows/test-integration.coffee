vows = require 'vows'
assert = require 'assert'

u = require 'underscore'
Rel = require '../rel'

tests = vows.describe('Integrating rel').addBatch
  'it should perform a users find': ->
    users = new Rel.Table 'users'
    assert.equal users.where(users.column('name').eq('amy')).toSql(), 'SELECT FROM "users" WHERE "users"."name" = "amy"'

  'it should run through the first example on the readme': ->
    users = new Rel.Table 'users'
    assert.equal users.project(Rel.star()).toSql(), 'SELECT * FROM "users"'

  'testing the or example': ->
    users = new Rel.Table 'users'
    sql = 'SELECT FROM "users" WHERE ("users"."name" = "bob" OR "users"."age" < 26)'
    assert.equal users.where(users.column('name').eq('bob').or(users.column('age').lt(26))).toSql(), sql

tests.export module


vows = require 'vows'
assert = require 'assert'
require 'date-utils'

UpdateManager = require '../lib/update-manager'
Table = require '../lib/table'
SqlLiteral = require('../lib/nodes/sql-literal')
Rel = require('../rel')
Nodes = require '../lib/nodes/nodes'

tests = vows.describe('Updating stuff').addBatch
  'An insert manager':
    'new': ->
      assert.isNotNull new UpdateManager()

    # TODO not sure how this would work, can't find limit in to_sql in ruby.
    # 'it handles limit properly': ->
    #   table = new Table 'users'
    #   um = new UpdateManager()
    #   um.take 10
    #   um.table table
    #   um.set [[table.column('name'), null]]
    #   assert.equal um.toSql(), 'UPDATE "users" SET "name" = NULL LIMIT 10'

    'set':
      'updates with null': ->
        table = new Table 'users'
        um = new UpdateManager()
        um.table table
        um.set [[table.column('name'), null]]
        assert.equal um.toSql(), 'UPDATE "users" SET "name" = NULL'

      'takes a string': ->
        table = new Table 'users'
        um = new UpdateManager()
        um.table table
        um.set new Nodes.SqlLiteral("foo = bar")
        assert.equal um.toSql(), 'UPDATE "users" SET foo = bar'

      'takes a list of lists': ->
        table = new Table 'users'
        um = new UpdateManager()
        um.table table
        um.set [[table.column('id'), 1], [table.column('name'), 'hello']]
        assert.equal um.toSql(), 'UPDATE "users" SET "id" = 1, "name" = "hello"'

      'chains': ->
        table = new Table 'users'
        um = new UpdateManager()
        assert.equal um.set([[table.column('id'), 1], [table.column('name'), 'hello']]).constructor, UpdateManager

    'table':
      'generates an update statement': ->
        um = new UpdateManager()
        um.table(new Table('users'))
        assert.equal um.toSql(), 'UPDATE "users"'

      'chains': ->
        um = new UpdateManager()
        assert.equal um.table(new Table('users')).constructor, UpdateManager

    'where':
      'generates a where clause': ->
        table = new Table 'users'
        um = new UpdateManager()
        um.table table
        um.where table.column('id').eq(1)
        assert.equal um.toSql(), 'UPDATE "users" WHERE "users"."id" = 1'

      'chains': ->
        table = new Table 'users'
        um = new UpdateManager()
        um.table table
        assert.equal um.where(table.column('id').eq(1)).constructor, UpdateManager





tests.export module

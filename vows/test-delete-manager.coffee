vows = require 'vows'
assert = require 'assert'

u = require 'underscore'
Table = require '../lib/table'
DeleteManager = require '../lib/delete-manager'
SqlLiteral = require('../lib/nodes/sql-literal')
Nodes = require '../lib/nodes/nodes'

tests = vows.describe('Deleting stuff').addBatch
  'Delete manager':
    'init': ->
      assert.isNotNull new DeleteManager()

    'from':
      'users from': ->
        table = new Table 'users'
        dm = new DeleteManager()
        dm.from table
        assert.equal dm.toSql(), 'DELETE FROM "users"'

      'chains': ->
        table = new Table 'users'
        dm = new DeleteManager()
        assert.equal dm.from(table).constructor, DeleteManager

    'where':
      'uses where values': ->
        table = new Table 'users'
        dm = new DeleteManager()
        dm.from table
        dm.where table.column('id').eq(10)
        assert.equal dm.toSql(), 'DELETE FROM "users" WHERE "users"."id" = 10'

      'chains': ->
        table = new Table 'users'
        dm = new DeleteManager()
        assert.equal dm.where(table.column('id').eq(10)).constructor, DeleteManager


tests.export module

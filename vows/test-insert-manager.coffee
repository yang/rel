vows = require 'vows'
assert = require 'assert'

SelectManager = require '../lib/select-manager'
InsertManager = require '../lib/insert-manager'
Table = require '../lib/table'
SqlLiteral = require('../lib/nodes/sql-literal')
Rel = require('../rel')
Nodes = require '../lib/nodes/nodes'

tests = vows.describe('Inserting stuff').addBatch
  'An insert manager':
    'new': ->
      assert.isNotNull new InsertManager()

    'can create a Values node': ->
      table = new Table 'users'
      manager = new InsertManager()
      values = manager.createValues ['a', 'b'], ['c', 'd']

      assert.equal values.left.length, ['a', 'b'].length
      assert.equal values.right.length, ['c', 'd'].length

    'allows sql literals': ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.values(manager.createValues [Rel.star()], ['a'])
      assert.equal manager.toSql(), 'INSERT INTO NULL VALUES (*)'

tests.export module

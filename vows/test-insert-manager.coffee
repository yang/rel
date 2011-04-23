vows = require 'vows'
assert = require 'assert'
require 'date-utils'

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

    'inserts false': ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.insert [[table.column('bool'), false]]
      assert.equal manager.toSql(), 'INSERT INTO "users" ("bool") VALUES (\'f\')'

    'inserts null': ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.insert [[table.column('id'), null]]
      assert.equal manager.toSql(), 'INSERT INTO "users" ("id") VALUES (NULL)'

    'inserts time': ->
      table = new Table 'users'
      manager = new InsertManager()

      time = new Date()
      attribute = table.column('created_at')

      manager.insert [[attribute, time]]
      assert.equal manager.toSql(), "INSERT INTO \"users\" (\"created_at\") VALUES (#{time.toDBString()})"

    'takes a list of lists': ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.into table
      manager.insert [[table.column('id'), 1], [table.column('name'), 'carl']]
      assert.equal manager.toSql(), 'INSERT INTO "users" ("id", "name") VALUES (1, "carl")'




tests.export module

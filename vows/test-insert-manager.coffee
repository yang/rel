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

    'defaults the table': ->
      table = new Table 'users'
      manager = new InsertManager()
      manager.insert [[table.column('id'), 1], [table.column('name'), 'carl']]
      assert.equal manager.toSql(), 'INSERT INTO "users" ("id", "name") VALUES (1, "carl")'

    'it takes an empty list': ->
      manager = new InsertManager()
      manager.insert []
      assert.isNull manager.ast.values

    'into':
      'converts to sql': ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table
        assert.equal manager.toSql(), 'INSERT INTO "users"'

    'columns':
      'converts to sql': ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table
        manager.columns().push table.column('id')
        assert.equal manager.toSql(), 'INSERT INTO "users" ("id")'

    'values':
      'converts to sql': ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table

        manager.values(new Nodes.Values([1]))
        assert.equal manager.toSql(), 'INSERT INTO "users" VALUES (1)'

    'combo':
      'puts shit together': ->
        table = new Table 'users'
        manager = new InsertManager()
        manager.into table

        manager.values(new Nodes.Values([1, 'carl']))
        manager.columns().push table.column('id')
        manager.columns().push table.column('name')

        assert.equal manager.toSql(), 'INSERT INTO "users" ("id", "name") VALUES (1, "carl")'




    




tests.export module

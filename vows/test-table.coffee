vows = require 'vows'
assert = require 'assert'

u = require 'underscore'
Table = require '../lib/table'
SelectManager = require '../lib/select-manager'
InsertManager = require '../lib/insert-manager'
SqlLiteral = require('../lib/nodes/sql-literal')
Nodes = require '../lib/nodes/nodes'

tests = vows.describe('Table stuff').addBatch
  'A table':
    topic: ->
      new Table('users')

    'it has a from method': (table) ->
      assert.isNotNull table.from('user')

    'it can project things': (table) ->
      assert.isNotNull table.project(new require('../lib/nodes/sql-literal')('*'))

    'it should return sql': (table) ->
      assert.equal table.project(new SqlLiteral('*')).toSql(), "SELECT * FROM \"users\""

    'it should create string join nodes': (table) ->
      join = table.createStringJoin('foo')
      assert.equal join.constructor, Nodes.StringJoin

    'it should create join nodes': (table) ->
      join = table.createJoin 'foo', 'bar'
      assert.equal join.constructor, Nodes.InnerJoin
      assert.equal join.left, 'foo'
      assert.equal join.right, 'bar'

    'it should create join nodes with a class': (table) ->
      join = table.createJoin 'foo', 'bar', Nodes.OuterJoin
      assert.equal join.constructor, Nodes.OuterJoin
      assert.equal join.left, 'foo'
      assert.equal join.right, 'bar'

    'should return an insert manager': (table) ->
      im = table.compileInsert 'VALUES(NULL)'
      assert.equal InsertManager, im.constructor
      assert.equal im.toSql(), 'INSERT INTO NULL VALUES(NULL)'

    'should return IM from insertManager': (table) ->
      im = table.insertManager()
      assert.equal InsertManager, im.constructor

    'skip: should add an offset': (table) ->
      sm = table.skip 2
      assert.equal sm.toSql(), 'SELECT FROM "users" OFFSET 2'

    'selectManager: should return a select manager': (table) ->
      sm = table.selectManager()
      assert.equal sm.toSql(), 'SELECT'

    'having: adds a having clause': (table) ->
      mgr = table.having table.column('id').eq(10)
      assert.equal mgr.toSql(), 'SELECT FROM "users" HAVING "users"."id" = 10'

    'group: should create a group': (table) ->
      mgr = table.group table.column('id')
      assert.equal mgr.toSql(), 'SELECT FROM "users" GROUP BY "users"."id"'

    'alias: should create a node that proxies a table': (table) ->
      assert.equal table.aliases.length, 0

      node = table.alias()
      assert.equal table.aliases.length, 1
      assert.equal node.name, 'users_2'
      assert.equal node.column('id').relation, node

    'new: takes a hash': ->
      rel = new Table 'users', as: 'users'
      assert.isNotNull rel.tableAlias

    'order: should take an order': (table) ->
      mgr = table.order 'foo'
      assert.equal mgr.toSql(), 'SELECT FROM "users" ORDER BY "foo"'

    'take: should add a limit': (table) ->
      mgr = table.take 1
      mgr.project new SqlLiteral('*')
      assert.equal mgr.toSql(), 'SELECT * FROM "users" LIMIT 1'

    'project: can project': (table) ->
      mgr = table.project new SqlLiteral('*')
      assert.equal mgr.toSql(), 'SELECT * FROM "users"'

    'project: takes multiple parameters': (table) ->
      mgr = table.project new SqlLiteral('*'), new SqlLiteral('*')
      assert.equal mgr.toSql(), 'SELECT *, * FROM "users"'

    'where: returns a tree manager': (table) ->
      mgr = table.where table.column('id').eq(1)
      mgr.project table.column('id')
      assert.equal mgr.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" = 1'

    'should have a name': (table) ->
      assert.equal table.name, 'users'

    'column': (table) ->
      column = table.column 'id'
      assert.equal column.name, 'id'




tests.export module

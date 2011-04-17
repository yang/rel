vows = require 'vows'
assert = require 'assert'

SelectManager = require '../lib/select-manager'
Table = require '../lib/table'
SqlLiteral = require('../lib/nodes/sql-literal')
Rel = require('../rel')
Nodes = require '../lib/nodes/nodes'

tests = vows.describe('Querying stuff').addBatch
  'A select manager':
    'projects':
      topic: ->
        new SelectManager(new Table('users'))
      'accepts sql literals and strings': (selectManager) ->
        selectManager.project 'id'
        assert.equal selectManager.toSql(), "SELECT id FROM \"users\""

    'order':
      topic: ->
        new SelectManager(new Table('users'))
      'accepts strings': (selectManager) ->
        selectManager.project new SqlLiteral('*')
        selectManager.order 'foo'
        assert.equal selectManager.toSql(), "SELECT * FROM \"users\" ORDER BY foo"


    'group':
      topic: ->
        new SelectManager(new Table('users'))
      'accepts strings': (selectManager) ->
        selectManager.project new SqlLiteral('*')
        selectManager.group 'foo'
        assert.equal selectManager.toSql(), "SELECT * FROM \"users\" GROUP BY foo"

    'as':
      topic: ->
        new SelectManager(new Table('users'))
      'makes an AS node by grouping the AST': (selectManager) ->
        as = selectManager.as Rel.sql('foo')
        assert.equal 'Grouping', as.left.constructor.name
        assert.equal selectManager.ast, as.left.expr
        assert.equal 'foo', as.right.toString()
      'it converts right to SqlLiteral if string': ->
        manager = new SelectManager(new Table('users'))
        as = manager.as Rel.sql('foo')
        assert.equal as.right.constructor.name, 'SqlLiteral'

    'from':
      'ignores string when table of same name exists': ->
        table = new Table('users')
        manager = new SelectManager(table)

        manager.from table
        manager.from 'users'
        manager.project table.attribute('id')
        assert.equal manager.toSql(), 'SELECT "users"."id" FROM "users"'
      'can have multiple items together': ->
        table = new Table('users')
        manager = table.from table
        manager.having 'foo', 'bar'
        assert.equal manager.toSql(), 'SELECT FROM "users" HAVING foo AND bar'

    'on':
      'converts to sql literals': ->
        table = new Table('users')
        right = table.alias()
        manager = table.from table
        manager.join(right).on('omg')
        assert.equal manager.toSql(), 'SELECT FROM "users" INNER JOIN "users" "users_2" ON omg'
      'converts to sql literals': ->
        table = new Table('users')
        right = table.alias()
        manager = table.from table
        manager.join(right).on('omg', "123")
        assert.equal manager.toSql(), 'SELECT FROM "users" INNER JOIN "users" "users_2" ON omg AND 123'

    # TODO Clone not implemented
    # 'clone':
    #   'creates new cores': ->
    #     table = new Table('users')
    #     table.as 'foo'
    #     mgr = table.from table
    #     m2 = mgr.clone()
    #     m2.project 'foo'
    #     assert.notEqual mgr.toSql(), m2.toSql()

    # TODO Test initialize

    'skip':
      'should add an offest': ->
        table = new Table 'users'
        mgr = table.from table
        mgr.skip 10
        assert.equal mgr.toSql(), 'SELECT FROM "users" OFFSET 10'








tests.export module


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
        assert.equal manager.toSql(), 'SELECT "users"."id" FROM users'
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
      'should chain': ->
        table = new Table 'users'
        mgr = table.from table
        assert.equal mgr.skip(10).toSql(), 'SELECT FROM "users" OFFSET 10'
      'should handle removing a skip': ->
        table = new Table 'users'
        mgr = table.from table
        assert.equal mgr.skip(10).toSql(), 'SELECT FROM "users" OFFSET 10'
        assert.equal mgr.skip(null).toSql(), 'SELECT FROM "users"'

    'exists':
      'should create an exists clause': ->
        table = new Table 'users'
        mgr = new SelectManager table
        mgr.project(new SqlLiteral('*'))
        m2 = new SelectManager
        m2.project mgr.exists()
        assert.equal m2.toSql(), "SELECT EXISTS (#{mgr.toSql()})"
      'can be aliased': ->
        table = new Table 'users'
        mgr = new SelectManager table
        mgr.project(new SqlLiteral('*'))
        m2 = new SelectManager()
        m2.project mgr.exists().as('foo')
        assert.equal m2.toSql(), "SELECT EXISTS (#{mgr.toSql()}) AS foo"

    'union':
      topic: ->
        table = new Table 'users'
        m1 = new SelectManager table
        m1.project Rel.star()
        m1.where(table.column('age').lt(18))

        m2 = new SelectManager table
        m2.project Rel.star()
        m2.where(table.column('age').gt(99))

        [m1, m2]

      'should union two managers': (topics) ->
        m1 = topics[0] 
        m2 = topics[1]
        node = m1.union m2
        assert.equal node.toSql(), 
          '( SELECT * FROM "users" WHERE "users"."age" < 18 UNION SELECT * FROM "users" WHERE "users"."age" > 99 )'
      'should union two managers': (topics) ->
        m1 = topics[0] 
        m2 = topics[1]
        node = m1.union 'all', m2
        assert.equal node.toSql(), 
          '( SELECT * FROM "users" WHERE "users"."age" < 18 UNION ALL SELECT * FROM "users" WHERE "users"."age" > 99 )'
    'except':
      topic: ->
        table = new Table 'users'
        m1 = new SelectManager table
        m1.project Rel.star()
        m1.where(table.column('age').in(Rel.range(18,60)))

        m2 = new SelectManager table
        m2.project Rel.star()
        m2.where(table.column('age').in(Rel.range(40,99)))

        [m1, m2]

      'should except two managers': (topics) ->
        m1 = topics[0] 
        m2 = topics[1]
        node = m1.except m2
        assert.equal node.toSql(), 
          '( SELECT * FROM "users" WHERE "users"."age" BETWEEN (18 AND 60) EXCEPT SELECT * FROM "users" WHERE "users"."age" BETWEEN (40 AND 99) )'
    'intersect':
      topic: ->
        table = new Table 'users'
        m1 = new SelectManager table
        m1.project Rel.star()
        m1.where(table.column('age').gt(18))

        m2 = new SelectManager table
        m2.project Rel.star()
        m2.where(table.column('age').lt(99))

        [m1, m2]

      'should intersect two managers': (topics) ->
        m1 = topics[0] 
        m2 = topics[1]
        node = m1.intersect m2

        assert.equal node.toSql(),
          '( SELECT * FROM "users" WHERE "users"."age" > 18 INTERSECT SELECT * FROM "users" WHERE "users"."age" < 99 )'














tests.export module


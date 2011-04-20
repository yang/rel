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

    'with':
      'should support WITH RECURSIVE': ->
        comments = new Table 'comments'
        commentsId = comments.column 'id'
        commentsParentId = comments.column 'parent_id'

        replies = new Table 'replies'
        repliedId = replies.column 'id'

        recursiveTerm = new SelectManager()
        recursiveTerm.from(comments).project(commentsId, commentsParentId).where(commentsId.eq(42))

        nonRecursiveTerm = new SelectManager()
        nonRecursiveTerm.from(comments).project(commentsId, commentsParentId).join(replies).on(commentsParentId.eq(repliedId))

        union = recursiveTerm.union(nonRecursiveTerm)

        asStatement = new Nodes.As replies, union

        manager = new SelectManager()
        manager.with('recursive', asStatement).from(replies).project(Rel.star())

        string = 'WITH RECURSIVE "replies" AS ( SELECT "comments"."id", "comments"."parent_id" FROM "comments" WHERE "comments"."id" = 42 UNION SELECT "comments"."id", "comments"."parent_id" FROM "comments" INNER JOIN "replies" ON "comments"."parent_id" = "replies"."id" ) SELECT * FROM "replies"'
        assert.equal manager.toSql(), string

    'ast':
      'it should return the ast': ->
        table = new Table 'users'
        mgr = table.from table
        ast = mgr.ast
        assert.equal mgr.visitor.accept(ast), mgr.toSql()

    'taken':
      'should return limit': ->
        manager = new SelectManager()
        manager.take(10)
        assert.equal manager.taken(), 10

    'lock':
      'adds a lock': ->
        table = new Table 'users'
        mgr = table.from table
        assert.equal mgr.lock().toSql(), 'SELECT FROM "users"'

    'orders':
      'returns order clauses': ->
        table = new Table 'users'
        manager = new SelectManager
        order = table.column 'id'
        manager.order table.column('id')
        assert.equal manager.orders()[0].name, order.name

    'order':
      'generates order clauses': ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.project Rel.star()
        manager.from table
        manager.order table.column('id')
        assert.equal manager.toSql(), 'SELECT * FROM "users" ORDER BY "users"."id"'

      'it takes args...': ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.project Rel.star()
        manager.from table
        manager.order table.column('id'), table.column('name')
        assert.equal manager.toSql(), 'SELECT * FROM "users" ORDER BY "users"."id", "users"."name"'

      'chains': ->
        table = new Table 'users'
        manager = new SelectManager()
        assert.equal manager.order(table.column('id')), manager

    'on':
      'takes two params': ->
        left = new Table 'users'
        right = left.alias()
        predicate = left.column('id').eq(right.column('id'))
        manager = new SelectManager()

        manager.from left
        manager.join(right).on(predicate, predicate)
        assert.equal manager.toSql(), 
          'SELECT FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id" AND "users"."id" = "users_2"."id"'

      'takes two params': ->
        left = new Table 'users'
        right = left.alias()
        predicate = left.column('id').eq(right.column('id'))
        manager = new SelectManager()

        manager.from left
        manager.join(right).on(predicate, predicate, left.column('name').eq(right.column('name')))
        assert.equal manager.toSql(), 
          'SELECT FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id" AND "users"."id" = "users_2"."id" AND "users"."name" = "users_2"."name"'

    'froms':
      'it should hand back froms': ->
        relation = new SelectManager()
        assert.equal [].length, relation.froms().length

    'nodes':
      'it should create AND nodes': ->
        relation = new SelectManager()
        children = ['foo', 'bar', 'baz']
        clause = relation.createAnd children
        assert.equal clause.constructor, Nodes.And
        assert.equal clause.children, children

      'it should create JOIN nodes': ->
        relation = new SelectManager()
        join = relation.createJoin 'foo', 'bar'
        assert.equal join.constructor, Nodes.InnerJoin
        assert.equal 'foo', join.left
        assert.equal 'bar', join.right

      'it should create JOIN nodes with a class': ->
        relation = new SelectManager()
        join = relation.createJoin 'foo', 'bar', Nodes.OuterJoin
        assert.equal join.constructor, Nodes.OuterJoin
        assert.equal 'foo', join.left
        assert.equal 'bar', join.right

    # TODO put in insert manager, see ruby tests.

    'join':
      'responds to join': ->
        left = new Table 'users'
        right = left.alias()
        predicate = left.column('id').eq(right.column('id'))
        manager = new SelectManager()

        manager.from left
        manager.join(right).on(predicate)
        assert.equal manager.toSql(), 'SELECT FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id"'

      'it takes a class': ->
        left = new Table 'users'
        right = left.alias()
        predicate = left.column('id').eq(right.column('id'))
        manager = new SelectManager()

        manager.from left
        manager.join(right, Nodes.OuterJoin).on(predicate)
        assert.equal manager.toSql(), 'SELECT FROM "users" LEFT OUTER JOIN "users" "users_2" ON "users"."id" = "users_2"."id"'

      'it noops on null': ->
        manager = new SelectManager()
        assert.equal manager.join(null), manager

    'joins':
      'returns join sql': ->
        table = new Table 'users'
        alias = table.alias()
        manager = new SelectManager()
        manager.from(new Nodes.InnerJoin(alias, table.column('id').eq(alias.column('id'))))
        assert.equal manager.joinSql().toString(), 'INNER JOIN "users" "users_2" "users"."id" = "users_2"."id"'

      'returns outer join sql': ->
        table = new Table 'users'
        alias = table.alias()
        manager = new SelectManager()
        manager.from(new Nodes.OuterJoin(alias, table.column('id').eq(alias.column('id'))))
        assert.equal manager.joinSql().toString(), 'LEFT OUTER JOIN "users" "users_2" "users"."id" = "users_2"."id"'

      'return string join sql': ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from new Nodes.StringJoin('hello')
        assert.equal manager.joinSql().toString(), '"hello"' # TODO not sure if this should get quoted. It isn't in ruby tests.

      'returns nil join sql': ->
        manager = new SelectManager()
        assert.isNull manager.joinSql()

    'order clauses':
      'returns order clauses as a list': ->
        table = new Table('users')
        manager = new SelectManager()
        manager.from table
        manager.order table.column('id')
        assert.equal manager.orderClauses()[0], '"users"."id"'

    'group':
      'takes an attribute': ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        manager.group table.column('id')
        assert.equal manager.toSql(), 'SELECT FROM "users" GROUP BY "users"."id"'

      'chaining': ->
        table = new Table 'users'
        manager = new SelectManager()
        assert.equal manager.group(table.column('id')).constructor.name, manager.constructor.name

      'takes multiple args': ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        manager.group table.column('id'), table.column('name')
        assert.equal manager.toSql(), 'SELECT FROM "users" GROUP BY "users"."id", "users"."name"'

      'it makes strings literals': ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        manager.group 'foo'
        assert.equal manager.toSql(), 'SELECT FROM "users" GROUP BY foo'

    # TODO Implement delete

    'where sql':
      'gives me back the where sql': ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        manager.where table.column('id').eq(10)
        assert.equal manager.whereSql(), 'WHERE "users"."id" = 10'
      'returns null when there are no wheres': ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from table
        assert.equal manager.whereSql(), null

    # TODO Implement Update

    'project':
      'takes multiple args': ->
        manager = new SelectManager()
        manager.project(new Nodes.SqlLiteral('foo'), new Nodes.SqlLiteral('bar'))
        assert.equal manager.toSql(), 'SELECT foo, bar'

      'takes strings': ->
        manager = new SelectManager()
        manager.project('*')
        assert.equal manager.toSql(), 'SELECT *'

      'takes sql literals': ->
        manager = new SelectManager()
        manager.project(new Nodes.SqlLiteral('*'))
        assert.equal manager.toSql(), 'SELECT *'

    'take':
      'knows take': ->
        table = new Table 'users'
        manager = new SelectManager()
        manager.from(table).project(table.column('id'))
        manager.where(table.column('id').eq(1))
        manager.take 1

        assert.equal manager.toSql(), 'SELECT "users"."id" FROM "users" WHERE "users"."id" = 1 LIMIT 1'

      'chains': ->
        manager = new SelectManager()
        assert.equal manager.take(1).constructor, SelectManager

      'removes limit when null is passed to take only (not limit)': ->
        manager = new SelectManager()
        manager.limit(10)
        manager.take(null)
        assert.equal manager.toSql(), 'SELECT'

    'join':
      'joins itself': ->
        left = new Table 'users'
        right = left.alias()
        predicate = left.column('id').eq(right.column('id'))

        mgr = left.join right
        mgr.project(new SqlLiteral('*'))
        assert.equal mgr.on(predicate).constructor, SelectManager

        assert.equal mgr.toSql(), 'SELECT * FROM "users" INNER JOIN "users" "users_2" ON "users"."id" = "users_2"."id"'

    'from':
      'makes sql': ->
        table = new Table 'users'
        manager = new SelectManager()

        manager.from table
        manager.project table.column('id')
        assert.equal manager.toSql(), 'SELECT "users"."id" FROM "users"'

      'chains': ->
        table = new Table 'users'
        manager = new SelectManager()
        assert.equal manager.from(table).project(table.column('id')).constructor, SelectManager
        assert.equal manager.toSql(), 'SELECT "users"."id" FROM "users"'


tests.export module


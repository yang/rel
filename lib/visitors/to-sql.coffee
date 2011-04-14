class ToSql
  constructor: ->
    @connection = nil
    @pool = nil
    @last_column = nil
    @quoted_tables = {}
    @quoted_columns = {}

  accept: (object) ->
    @last_column = nil
    @pool = null # TODO need to build out engines.
    @pool.withConnection (conn) ->
      @connection = conn
      super
  
  visitArelNodesDeleteStatement: (o) ->
    [
      "DELETE FROM #{visit o.relation}", 
    ]

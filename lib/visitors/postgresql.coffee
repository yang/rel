ToSql = require './to-sql'
pgcli = require 'pg/lib/client'

class Postgresql extends ToSql
  quote: (value, column=null) ->
    if value == null
      'NULL'
    else if value.constructor == Boolean
      if value == true then "true" else "false"
    else if value.constructor == Date
      value.toISOString()
    else if value.constructor == Number
      value
    else
      pgcli.prototype.escapeLiteral value

exports = module.exports = Postgresql

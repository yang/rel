u = require 'underscore'

class SqlLiteral extends String
  
  
Expressions = require('../expressions')
Predications = require('../predications')

u(SqlLiteral).extend(Expressions)
u(SqlLiteral).extend(SqlLiteral)

exports = module.exports = SqlLiteral
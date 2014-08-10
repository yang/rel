ToSql = require './to-sql'

`
escapeLiteral = function(str) {

  var hasBackslash = false;
  var escaped = '\'';

  for(var i = 0; i < str.length; i++) {
    var c = str[i];
    if(c === '\'') {
      escaped += c + c;
    } else if (c === '\\') {
      escaped += c + c;
      hasBackslash = true;
    } else {
      escaped += c;
    }
  }

  escaped += '\'';

  if(hasBackslash === true) {
    escaped = ' E' + escaped;
  }

  return escaped;
};
`

class Postgresql extends ToSql
  quote: (value, column=null) ->
    if value == null
      'NULL'
    else if value.constructor == Boolean
      if value == true then "true" else "false"
    else if value.constructor == Date
      @quote(value.toISOString())
    else if value.constructor == Number
      value
    else
      escapeLiteral value

exports = module.exports = Postgresql

# Presto client library for Ruby

Presto is a distributed SQL query engine for big data:
https://github.com/facebook/presto

This is a client library for Ruby to run queries on Presto.

## Example

```ruby
require 'presto-client'

# create a client object:
client = Presto::Client.new(
  server: "localhost:8880",
  catalog: "native",
  schema: "default",
  user: "frsyuki",
  http_debug: true,
)

# run a query and get results:
columns, rows = client.run("select * from sys.node")
rows.each {|row|
  p row
}

# another way to run a query and fetch results streamingly:
# start running a query on presto
client.query("select * from sys.node") do |q|
  # wait for completion and get columns
  q.columns.each {|column|
    puts "column: #{column.name}.#{column.type}"
  }

  # get query results
  q.each_row {|row|
    p row
  }
end
```

## Options

* **server** sets address[:port] to a Presto coordinator
* **catalog** sets catalog (connector) name of Presto such as `hive-cdh4`, `hive-hadoop1`, etc.
* **schema** sets default schema name of Presto. You can read other schemas by qualified name like `FROM myschema.table1`.
* **source** sets source name to connect to a Presto. This name is shown on Presto web interface.
* **user** sets user name to connect to a Presto.
* **time_zone** sets time zone of the query. Time zone affects some functions such as `format_datetime`.
* **language** sets language of the query. Language affects some functions such as `format_datetime`.
* **http_debug** enables debug message to STDOUT for each HTTP requests
* **http_open_timeout** sets timeout in seconds to open new HTTP connection
* **http_timeout** sets timeout in seconds to read data from a server


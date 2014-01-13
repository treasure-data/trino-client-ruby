# Presto client library for Ruby

Presto is a distributed SQL query engine for big data:
https://github.com/facebook/presto

This is a client library for Ruby to run queries on Presto.

## Example

```ruby
require 'presto-client'

# create a client object
client = Presto::Client.new(
  server: "localhost:8880",
  user: "frsyuki",
  catalog: "native",
  schema: "default",
)

# start running a query on presto
q = client.query("select * from sys.node")

# wait for completion and get columns
q.columns.each {|column|
  puts "column: #{column.name}.#{column.type}"
}

# get query results
q.each_row {|row|
  p row
}
```


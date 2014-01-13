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
  user: "frsyuki",
  catalog: "native",
  schema: "default",
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


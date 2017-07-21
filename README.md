# Presto client library for Ruby

[![Build Status](https://travis-ci.org/treasure-data/presto-client-ruby.svg?branch=master)](https://travis-ci.org/treasure-data/presto-client-ruby)

Presto is a distributed SQL query engine for big data:
https://github.com/facebook/presto

This is a client library for Ruby to run queries on Presto.

## Example

```ruby
require 'presto-client'

# create a client object:
client = Presto::Client.new(
  server: "localhost:8880",   # required option
  ssl: {verify: false},
  catalog: "native",
  schema: "default",
  user: "frsyuki",
  password: "********",
  time_zone: "US/Pacific",
  language: "English",
  properties: {
    "hive.force_local_scheduling": true,
    "raptor.reader_stream_buffer_size": "32MB"
  },
  http_proxy: "proxy.example.com:8080",
  http_debug: true,
)

# run a query and get results as an array of arrays:
columns, rows = client.run("select * from sys.node")
rows.each {|row|
  p row  # row is an array
}

# run a query and get results as an array of hashes:
results = client.run_with_names("select alpha, 1 AS beta from tablename")
results.each {|row|
  p row['alpha']   # access by name
  p row['beta']
  p row.values[0]  # access by index
  p row.values[1]
}

# run a query and fetch results streamingly:
client.query("select * from sys.node") do |q|
  # get columns:
  q.columns.each {|column|
    puts "column: #{column.name}.#{column.type}"
  }

  # get query results. it feeds more rows until
  # query execution finishes:
  q.each_row {|row|
    p row  # row is an array
  }
end
```

## Build models

```
$ bundle exec rake modelgen:latest
```

## Options

* **server** sets address (and port) of a Presto coordinator server.
* **ssl** enables https.
  * Setting `true` enables SSL and verifies server certificate using system's built-in certificates.
  * Setting `{verify: false}` enables SSL but doesn't verify server certificate.
  * Setting a Hash object enables SSL and verify server certificate with options:
    * **ca_file**: path of a CA certification file in PEM format
    * **ca_path**: path of a CA certification directory containing certifications in PEM format
    * **cert_store**: a `OpenSSL::X509::Store` object used for verification
    * **client_cert**: a `OpenSSL::X509::Certificate` object as client certificate
    * **client_key**: a `OpenSSL::PKey::RSA` or `OpenSSL::PKey::DSA` object used for client certificate
* **catalog** sets catalog (connector) name of Presto such as `hive-cdh4`, `hive-hadoop1`, etc.
* **schema** sets default schema name of Presto. You need to use qualified name like `FROM myschema.table1` to use non-default schemas.
* **source** sets source name to connect to a Presto. This name is shown on Presto web interface.
* **user** sets user name to connect to a Presto.
* **password** sets a password to connect to Presto using basic auth.
* **time_zone** sets time zone of queries. Time zone affects some functions such as `format_datetime`.
* **language** sets language of queries. Language affects some functions such as `format_datetime`.
* **properties** set session properties. Session properties affect internal behavior such as `hive.force_local_scheduling: true`, `raptor.reader_stream_buffer_size: "32MB"`, etc.
* **http_proxy** sets host:port of a HTTP proxy server.
* **http_debug** enables debug message to STDOUT for each HTTP requests.
* **http_open_timeout** sets timeout in seconds to open new HTTP connection.
* **http_timeout** sets timeout in seconds to read data from a server.
* **model_version** set the presto version to which a job is submitted. Supported versions are 0.153 and 0.149. Default is 0.153.

See [RDoc](http://www.rubydoc.info/gems/presto-client/) for the full documentation.

## Development

### Releasing a new version

1. Update lib/presto/client/version.rb
2. Update ChangeLog
3. git commit -am "vX.Y.Z"
4. git tag "vX.Y.Z"
5. git push --tags


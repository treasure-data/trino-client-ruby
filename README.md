# Presto client library for Ruby

[![Build Status](https://travis-ci.org/treasure-data/presto-client-ruby.svg?branch=master)](https://travis-ci.org/treasure-data/presto-client-ruby) [![Gem](https://img.shields.io/gem/v/presto-client)](https://rubygems.org/gems/presto-client) [![Gem](https://img.shields.io/gem/dt/presto-client)](https://rubygems.org/gems/presto-client) [![GitHub](https://img.shields.io/github/license/treasure-data/presto-client-ruby)]()

Presto is a distributed SQL query engine for big data:
https://prestosql.io/

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

# killing a query
query = client.query("select * from sys.node")
query_id = query.query_info.query_id
query.each_row {|row| ... }  # when a thread is processing the query,
client.kill(query_id)  # another thread / process can kill the query.
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
* **client_info** sets client info to queries. It can be a string to pass a raw string, or an object that can be encoded to JSON.
* **client_tags** sets client tags to queries. It needs to be an array of strings. The tags are shown on web interface.
* **user** sets user name to connect to a Presto.
* **password** sets a password to connect to Presto using basic auth.
* **time_zone** sets time zone of queries. Time zone affects some functions such as `format_datetime`.
* **language** sets language of queries. Language affects some functions such as `format_datetime`.
* **properties** set session properties. Session properties affect internal behavior such as `hive.force_local_scheduling: true`, `raptor.reader_stream_buffer_size: "32MB"`, etc.
* **query_timeout** sets timeout in seconds for the entire query execution (from the first API call until there're no more output data). If timeout happens, client raises PrestoQueryTimeoutError. Default is nil (disabled).
* **plan_timeout** sets timeout in seconds for query planning execution (from the first API call until result columns become available). If timeout happens, client raises PrestoQueryTimeoutError. Default is nil (disabled).
* **http_headers** sets custom HTTP headers. It must be a Hash of string to string.
* **http_proxy** sets host:port of a HTTP proxy server.
* **http_debug** enables debug message to STDOUT for each HTTP requests.
* **http_open_timeout** sets timeout in seconds to open new HTTP connection.
* **http_timeout** sets timeout in seconds to read data from a server.
* **model_version** set the presto version to which a job is submitted. Supported versions are 316, 303, 0.205, 0.178, 0.173, 0.153 and 0.149. Default is 316.

See [RDoc](http://www.rubydoc.info/gems/presto-client/) for the full documentation.

## Development

### Releasing a new version

1. First update `lib/presto/client/version.rb` to the next version.
2. Run the following command which will update `ChangeLog.md` file automatically.
```
$ ruby release.rb
```

3. Create tag
```
$ git commit -am "vX.Y.Z"
$ git tag "vX.Y.Z"
% git push --tags
```

4. Push package
```
$ gem build presto-client.gemspec
$ gem push presto-client-X.Y.Z.gem
```

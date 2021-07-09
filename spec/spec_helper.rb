require 'bundler'

begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'simplecov'
SimpleCov.start

require 'json'
require 'webmock/rspec'

require 'trino-client'
include Trino::Client

require 'tiny-presto'

MAX_RETRY_COUNT = 5
RETRYABLE_ERRORS = [
  /No nodes available to run query/
]

def run_with_retry(client, sql)
  i = 0
  while i < MAX_RETRY_COUNT
    begin
      columns, rows = @client.run(sql)
      return columns, rows
    rescue Trino::Client::TrinoQueryError => e
      if RETRYABLE_ERRORS.any? { |error| e.message =~ error }
        sleep(i)
        i += 1
        next
      end
      raise "Fail to run query: #{e}"
    end
  end
end

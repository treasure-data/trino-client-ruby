#
# Presto client for Ruby
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
module Presto::Client

  require 'faraday'
  require 'presto/client/models'
  require 'presto/client/errors'
  require 'presto/client/statement_client'

  class Query
    def self.start(query, options)
      server = options[:server]
      unless server
        raise ArgumentError, ":server option is required"
      end

      faraday = Faraday.new(url: "http://#{server}") do |faraday|
        #faraday.request :url_encoded
        faraday.response :logger if options[:http_debug]
        faraday.adapter Faraday.default_adapter
      end

      new StatementClient.new(faraday, query, options)
    end

    def initialize(client)
      @client = client
    end

    attr_reader :client

    def wait_for_data
      while @client.current_results.data == nil && @client.advance
      end
    end

    private :wait_for_data

    def columns
      wait_for_data

      raise_error unless @client.query_succeeded?

      return @client.current_results.columns
    end

    def rows
      rows = []
      each_row_chunk {|chunk|
        rows.concat(chunk)
      }
      return rows
    end

    def each_row(&block)
      each_row_chunk {|chunk|
        chunk.each(&block)
      }
    end

    def each_row_chunk(&block)
      wait_for_data

      raise_error unless @client.query_succeeded?

      if self.columns == nil
        raise PrestoError, "Query #{@client.current_results.id} has no columns"
      end

      begin
        if data = @client.current_results.data
          block.call(data)
        end
      end while @client.advance
    end

    def cancel
      @client.cancel_leaf_stage
    end

    def close
      @client.cancel_leaf_stage
      nil
    end

    def raise_error
      if @client.closed?
        raise PrestoClientError, "Query aborted by user"
      elsif @client.exception?
        # query is gone
        raise @client.exception
      elsif @client.query_failed?
        results = @client.current_results
        error = results.error
        raise PrestoQueryError.new("Query #{results.id} failed: #{error.message}", results.id, error.error_code, error.failure_info)
      end
    end

    private :raise_error
  end

end

#
# Trino client for Ruby
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
module Trino::Client

  require 'faraday'
  require 'faraday_middleware'
  require 'trino/client/models'
  require 'trino/client/errors'
  require 'trino/client/faraday_client'
  require 'trino/client/statement_client'

  class Query
    def self.start(query, options)
      new StatementClient.new(faraday_client(options), query, options)
    end

    def self.resume(next_uri, options)
      new StatementClient.new(faraday_client(options), nil, options, next_uri)
    end

    def self.kill(query_id, options)
      faraday = faraday_client(options)
      response = faraday.delete do |req|
        req.url "/v1/query/#{query_id}"
      end
      return response.status / 100 == 2
    end

    def self.faraday_client(options)
      Trino::Client.faraday_client(options)
    end

    def initialize(api)
      @api = api
    end

    def current_results
      @api.current_results
    end

    def current_results_headers
      @api.current_results_headers
    end

    def advance
      @api.advance
    end

    def advance_and_raise
      cont = @api.advance
      raise_if_failed
      cont
    end

    def wait_for_columns
      while @api.current_results.columns == nil && advance_and_raise
      end
    end

    def wait_for_data
      while @api.current_results.data == nil && advance_and_raise
      end
    end

    private :advance_and_raise
    private :wait_for_columns
    private :wait_for_data

    def columns
      wait_for_columns

      return @api.current_results.columns
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

      if self.columns == nil
        raise TrinoError, "Query #{@api.current_results.id} has no columns"
      end

      begin
        if data = @api.current_results.data
          block.call(data)
        end
      end while advance_and_raise
    end

    def query_info
      @api.query_info
    end

    def next_uri
      @api.current_results.next_uri
    end

    def cancel
      @api.cancel_leaf_stage
    end

    def close
      @api.close
      nil
    end

    def raise_if_failed
      if @api.client_aborted?
        raise TrinoClientError, "Query aborted by user"
      elsif @api.query_failed?
        results = @api.current_results
        error = results.error
        raise TrinoQueryError.new("Query #{results.id} failed: #{error.message}", results.id, error.error_code, error.error_name, error.error_type, error.error_location, error.failure_info)
      end
    end
  end

end

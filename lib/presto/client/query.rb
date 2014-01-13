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
    def self.start(session, query)
      faraday = Faraday.new(url: "http://#{session.server}") do |faraday|
        #faraday.request :url_encoded
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end

      new StatementClient.new(faraday, session, query)
    end

    def initialize(client)
      @client = client
    end

    attr_reader :client

    def wait_for_data
      while @client.has_next? && @client.current_results.data == nil
        @client.advance
      end
    end

    private :wait_for_data

    def columns
      wait_for_data

      raise_error unless @client.query_succeeded?

      return @client.current_results.columns
    end

    def each_row(&block)
      wait_for_data

      raise_error unless @client.query_succeeded?

      if self.columns == nil
        raise PrestoError, "Query #{@client.current_results.id} has no columns"
      end

      begin
        if data = @client.current_results.data
          data.each(&block)
        end
        @client.advance
      end while @client.has_next?
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
        unless error
          raise PrestoQueryError.new("Query #{results.id} failed: (unknown reason)", results.id, nil, nil)
        end
        raise PrestoQueryError.new("Query #{results.id} failed: #{error.message}", results.id, error.error_code, error.failure_info)
      end
    end

    private :raise_error
  end

end

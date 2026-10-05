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

  require 'trino/client/models'
  require 'trino/client/query'

  class Client
    # Creates a reusable Faraday connection using the initial options.
    # Connection settings are not reapplied after initialization.
    # These include server, ssl, proxy, and faraday_adapter; see the README for the full list.
    # Create a new Client to change these settings.
    #
    # Query-specific headers, including Basic Auth, use the options at query start.
    # Password authentication requires the actual connection to use HTTPS, regardless of later changes to options[:ssl].
    def initialize(options)
      @options = options
      @faraday = Trino::Client.faraday_client(options)
    end

    def query(query, &block)
      q = Query.start(query, @faraday, @options)
      if block
        begin
          yield q
        ensure
          q.close
        end
      else
        return q
      end
    end

    def resume_query(next_uri)
      return Query.resume(next_uri, @faraday, @options)
    end

    def kill(query_id)
      return Query.kill(query_id, @faraday, @options)
    end

    def run(query)
      q = Query.start(query, @faraday, @options)
      begin
        columns = q.columns
        if columns.empty?
          return [], []
        end
        return columns, q.rows
      ensure
        q.close
      end
    end

    # Accepts the raw response from the Trino Client and returns an
    # array of hashes where you can access the data in each row using the
    # output name specified in the query with AS:
    #   SELECT expression AS output_name
    def run_with_names(query)
      columns, rows = run(query)

      column_names = columns.map(&:name)

      rows.map do |row|
        Hash[column_names.zip(row)]
      end
    end
  end

  def self.new(...)
    Client.new(...)
  end
end

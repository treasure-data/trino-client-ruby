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
      new StatementClient.new(faraday_client(options), query, options)
    end

    def self.resume(next_uri, options)
      new StatementClient.new(faraday_client(options), nil, options, next_uri)
    end

    def self.faraday_client(options)
      server = options[:server]
      unless server
        raise ArgumentError, ":server option is required"
      end

      ssl = faraday_ssl_options(options)

      if options[:password] && !ssl
        raise ArgumentError, "Protocol must be https when passing a password"
      end

      url = "#{ssl ? "https" : "http"}://#{server}"
      proxy = options[:http_proxy] || options[:proxy]  # :proxy is obsoleted

      faraday_options = {url: url, proxy: "#{proxy}"}
      faraday_options[:ssl] = ssl if ssl

      faraday = Faraday.new(faraday_options) do |faraday|
        #faraday.request :url_encoded

        if options[:user] && options[:password]
          faraday.basic_auth(options[:user], options[:password])
        end

        faraday.response :logger if options[:http_debug]
        faraday.adapter Faraday.default_adapter
      end

      return faraday
    end

    def self.faraday_ssl_options(options)
      ssl = options[:ssl]

      case ssl
      when true
        ssl = {verify: true}

      when Hash
        verify = ssl.fetch(:verify, true)
        case verify
        when true
          # detailed SSL options. pass through to faraday
        when nil, false
          ssl = {verify: false}
        else
          raise ArgumentError, "Can't convert #{verify.class} of :verify option of :ssl option to true or false"
        end

      when nil, false
        ssl = false

      else
        raise ArgumentError, "Can't convert #{ssl.class} of :ssl option to true, false, or Hash"
      end

      return ssl
    end

    private_class_method :faraday_client, :faraday_ssl_options

    def initialize(api)
      @api = api
    end

    def current_results
      @api.current_results
    end

    def advance
      @api.advance
    end

    def wait_for_columns
      while @api.current_results.columns == nil && @api.advance
      end
    end

    def wait_for_data
      while @api.current_results.data == nil && @api.advance
      end
    end

    private :wait_for_columns
    private :wait_for_data

    def columns
      wait_for_columns

      raise_if_failed

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

      raise_if_failed

      if self.columns == nil
        raise PrestoError, "Query #{@api.current_results.id} has no columns"
      end

      begin
        if data = @api.current_results.data
          block.call(data)
        end
      end while @api.advance
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
      @api.cancel_leaf_stage
      nil
    end

    def raise_if_failed
      if @api.closed?
        raise PrestoClientError, "Query aborted by user"
      elsif @api.exception?
        # query is gone
        raise @api.exception
      elsif @api.query_failed?
        results = @api.current_results
        error = results.error
        raise PrestoQueryError.new("Query #{results.id} failed: #{error.message}", results.id, error.error_code, error.failure_info)
      end
    end
  end

end

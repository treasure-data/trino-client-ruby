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

  require 'json'
  require 'msgpack'
  require 'trino/client/models'
  require 'trino/client/errors'

  class StatementClient
    # Trino can return too deep nested JSON
    JSON_OPTIONS = {
        :max_nesting => false
    }

    def initialize(faraday, query, options, next_uri=nil)
      @faraday = faraday

      @options = options
      @query = query
      @state = :running
      @retry_timeout = options[:retry_timeout] || 120
      if model_version = @options[:model_version]
        @models = ModelVersions.const_get("V#{model_version.gsub(".", "_")}")
      else
        @models = Models
      end

      @plan_timeout = options[:plan_timeout]
      @query_timeout = options[:query_timeout]

      if @plan_timeout || @query_timeout
        # this is set before the first call of faraday_get_with_retry so that
        # resuming StatementClient with next_uri is also under timeout control.
        @started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      if next_uri
        response = faraday_get_with_retry(next_uri)
        @results_headers = response.headers
        @results = @models::QueryResults.decode(parse_body(response))
      else
        post_query_request!
      end
    end

    def init_request(req)
      req.options.timeout = @options[:http_timeout] || 300
      req.options.open_timeout = @options[:http_open_timeout] || 60
    end

    private :init_request

    def post_query_request!
      uri = "/v1/statement"
      response = @faraday.post do |req|
        req.url uri

        req.body = @query
        init_request(req)
      end

      # TODO error handling
      if response.status != 200
        exception! TrinoHttpError.new(response.status, "Failed to start query: #{response.body} (#{response.status})")
      end

      @results_headers = response.headers
      @results = decode_model(uri, parse_body(response), @models::QueryResults)
    end

    private :post_query_request!

    attr_reader :query

    def debug?
      !!@options[:debug]
    end

    def running?
      @state == :running
    end

    def client_aborted?
      @state == :client_aborted
    end

    def client_error?
      @state == :client_error
    end

    def finished?
      @state == :finished
    end

    def query_failed?
      @results.error != nil
    end

    def query_succeeded?
      @results.error == nil && finished?
    end

    def current_results
      @results
    end

    def current_results_headers
      @results_headers
    end

    def query_id
      @results.id
    end

    def has_next?
      !!@results.next_uri
    end

    def exception!(e)
      @state = :client_error
      raise e
    end

    def advance
      return false unless running?

      unless has_next?
        @state = :finished
        return false
      end

      uri = @results.next_uri

      response = faraday_get_with_retry(uri)
      @results_headers = response.headers
      @results = decode_model(uri, parse_body(response), @models::QueryResults)

      raise_if_timeout!

      return true
    end

    def query_info
      uri = "/v1/query/#{@results.id}"
      response = faraday_get_with_retry(uri)
      decode_model(uri, parse_body(response), @models::QueryInfo)
    end

    def decode_model(uri, hash, body_class)
      begin
        body_class.decode(hash)
      rescue => e
        body = JSON.dump(hash)
        if body.size > 1024 + 3
          body = "#{body[0, 1024]}..."
        end
        exception! TrinoHttpError.new(500, "Trino API returned unexpected structure at #{uri}. Expected #{body_class} but got #{body}: #{e}")
      end
    end

    private :decode_model

    def parse_body(response)
      begin
        case response.headers['Content-Type']
        when 'application/x-msgpack'
          MessagePack.load(response.body)
        else
          JSON.parse(response.body, opts = JSON_OPTIONS)
        end
      rescue => e
        exception! TrinoHttpError.new(500, "Trino API returned unexpected data format. #{e}")
      end
    end

    private :parse_body

    def faraday_get_with_retry(uri, &block)
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      attempts = 0

      begin
        begin
          response = @faraday.get(uri)
        rescue Faraday::TimeoutError, Faraday::ConnectionFailed
          # temporally error to retry
          response = nil
        rescue => e
          exception! e
        end

        if response
          if response.status == 200 && !response.body.to_s.empty?
            return response
          end

          if response.status != 503  # retry only if 503 Service Unavailable
            # deterministic error
            exception! TrinoHttpError.new(response.status, "Trino API error at #{uri} returned #{response.status}: #{response.body}")
          end
        end

        raise_if_timeout!

        attempts += 1
        sleep attempts * 0.1
      end while (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) < @retry_timeout && !client_aborted?

      exception! TrinoHttpError.new(408, "Trino API error due to timeout")
    end

    def raise_if_timeout!
      if @started_at
        return if finished?

        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @started_at

        if @query_timeout && elapsed > @query_timeout
          raise_timeout_error!
        end

        if @plan_timeout && (@results == nil || @results.columns == nil) &&
            elapsed > @plan_timeout
          # @results is not set (even first faraday_get_with_retry isn't called yet) or
          # result from Trino doesn't include result schema. Query planning isn't done yet.
          raise_timeout_error!
        end
      end
    end

    def raise_timeout_error!
      if query_id = @results && @results.id
        exception! TrinoQueryTimeoutError.new("Query #{query_id} timed out")
      else
        exception! TrinoQueryTimeoutError.new("Query timed out")
      end
    end

    def cancel_leaf_stage
      if uri = @results.partial_cancel_uri
        @faraday.delete do |req|
          req.url uri
        end
      end
    end

    def close
      return unless running?

      @state = :client_aborted

      begin
        if uri = @results.next_uri
          @faraday.delete do |req|
            req.url uri
          end
        end
      rescue => e
      end

      nil
    end
  end

end

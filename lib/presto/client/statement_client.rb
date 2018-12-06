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

  require 'json'
  require 'msgpack'
  require 'presto/client/models'
  require 'presto/client/errors'

  class StatementClient
    # Presto can return too deep nested JSON
    JSON_OPTIONS = {
        :max_nesting => false
    }

    def initialize(faraday, query, options, next_uri=nil)
      @faraday = faraday

      @options = options
      @query = query
      @closed = false
      @exception = nil
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
        @query_submitted_at = Time.now
      end

      if next_uri
        response = faraday_get_with_retry(next_uri)
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
        raise PrestoHttpError.new(response.status, "Failed to start query: #{response.body} (#{response.status})")
      end

      @results = decode_model(uri, parse_body(response), @models::QueryResults)
    end

    private :post_query_request!

    attr_reader :query

    def debug?
      !!@options[:debug]
    end

    def closed?
      @closed
    end

    attr_reader :exception

    def exception?
      @exception
    end

    def query_failed?
      @results.error != nil
    end

    def query_succeeded?
      @results.error == nil && !@exception && !@closed
    end

    def current_results
      @results
    end

    def has_next?
      !!@results.next_uri
    end

    def advance
      if closed? || !has_next?
        return false
      end

      uri = @results.next_uri
      response = faraday_get_with_retry(uri)
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
        @exception = PrestoHttpError.new(500, "Presto API returned unexpected structure at #{uri}. Expected #{body_class} but got #{body}: #{e}")
        raise @exception
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
        @exception = PrestoHttpError.new(500, "Presto API returned unexpected data format. #{e}")
        raise @exception
      end
    end

    private :parse_body

    def faraday_get_with_retry(uri, &block)
      start = Time.now
      attempts = 0

      begin
        begin
          response = @faraday.get(uri)
        rescue Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed
          # temporally error to retry
          response = nil
        rescue => e
          @exception = e
          raise @exception
        end

        if response
          if response.status == 200 && !response.body.to_s.empty?
            return response
          end

          if response.status != 503  # retry only if 503 Service Unavailable
            # deterministic error
            @exception = PrestoHttpError.new(response.status, "Presto API error at #{uri} returned #{response.status}: #{response.body}")
            raise @exception
          end
        end

        raise_if_timeout!

        attempts += 1
        sleep attempts * 0.1
      end while (Time.now - start) < @retry_timeout && !@closed

      @exception = PrestoHttpError.new(408, "Presto API error due to timeout")
      raise @exception
    end

    def raise_if_timeout!
      if @query_submitted_at
        if @results && @results.next_uri == nil
          # query is already done
          return
        end

        elapsed = Time.now - @query_submitted_at

        if @query_timeout && elapsed > @query_timeout
          raise_timeout_error!
        end

        if @plan_timeout && (@results == nil || @results.columns == nil) &&
            elapsed > @plan_timeout
          # @results is not set (even first faraday_get_with_retry isn't called yet) or
          # result from Presto doesn't include result schema. Query planning isn't done yet.
          raise_timeout_error!
        end
      end
    end

    def raise_timeout_error!
      if query_id = @results && @results.id
        raise PrestoQueryTimeoutError, "Query #{query_id} timed out"
      else
        raise PrestoQueryTimeoutError, "Query timed out"
      end
    end

    def cancel_leaf_stage
      if uri = @results.next_uri
        response = @faraday.delete do |req|
          req.url uri
        end
        return response.status / 100 == 2
      end
      return false
    end

    def close
      return if @closed

      # cancel running statement
      # TODO make async reqeust and ignore response?
      cancel_leaf_stage

      @closed = true
      nil
    end
  end

end

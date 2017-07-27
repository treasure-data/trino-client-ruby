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

  require 'multi_json'
  require 'msgpack'
  require 'presto/client/models'
  require 'presto/client/errors'

  module PrestoHeaders
    PRESTO_USER = "X-Presto-User"
    PRESTO_SOURCE = "X-Presto-Source"
    PRESTO_CATALOG = "X-Presto-Catalog"
    PRESTO_SCHEMA = "X-Presto-Schema"
    PRESTO_TIME_ZONE = "X-Presto-Time-Zone"
    PRESTO_LANGUAGE = "X-Presto-Language"
    PRESTO_SESSION = "X-Presto-Session"

    PRESTO_CURRENT_STATE = "X-Presto-Current-State"
    PRESTO_MAX_WAIT = "X-Presto-Max-Wait"
    PRESTO_MAX_SIZE = "X-Presto-Max-Size"
    PRESTO_PAGE_SEQUENCE_ID = "X-Presto-Page-Sequence-Id"
  end

  class StatementClient
    HEADERS = {
      "User-Agent" => "presto-ruby/#{VERSION}",
    }

    def initialize(faraday, query, options, next_uri=nil)
      @faraday = faraday
      @faraday.headers.merge!(HEADERS)

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

      @faraday.headers.merge!(optional_headers)

      if next_uri
        response = faraday_get_with_retry(next_uri)
        @results = @models::QueryResults.decode(parse_body(response))
      else
        post_query_request!
      end
    end

    def optional_headers
      headers = {}
      if v = @options[:user]
        headers[PrestoHeaders::PRESTO_USER] = v
      end
      if v = @options[:source]
        headers[PrestoHeaders::PRESTO_SOURCE] = v
      end
      if v = @options[:catalog]
        headers[PrestoHeaders::PRESTO_CATALOG] = v
      end
      if v = @options[:schema]
        headers[PrestoHeaders::PRESTO_SCHEMA] = v
      end
      if v = @options[:time_zone]
        headers[PrestoHeaders::PRESTO_TIME_ZONE] = v
      end
      if v = @options[:language]
        headers[PrestoHeaders::PRESTO_LANGUAGE] = v
      end
      if v = @options[:properties]
        headers[PrestoHeaders::PRESTO_SESSION] = encode_properties(v)
      end
      if @options[:enable_x_msgpack]
        # option name is enable_"x"_msgpack because "Accept: application/x-msgpack" header is
        # not officially supported by Presto. We can use this option only if a proxy server
        # decodes & encodes response body. Once this option is supported by Presto, option
        # name should be enable_msgpack, which might be slightly different behavior.
        headers['Accept'] = 'application/x-msgpack,application/json'
      end
      headers
    end

    private :optional_headers

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
        if body.size > 1024 + 3
          body = "#{body[0, 1024]}..."
        end
        @exception = PrestoHttpError.new(500, "Presto API returned unexpected structure at #{uri}. Expected #{body_class} but got #{body}: #{e}")
        raise @exception
      end
    end

    private :decode_model

    def parse_body(response)
      case response.headers['Content-Type']
      when 'application/x-msgpack'
        MessagePack.load(response.body)
      else
        MultiJson.load(response.body)
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

        attempts += 1
        sleep attempts * 0.1
      end while (Time.now - start) < @retry_timeout && !@closed

      @exception = PrestoHttpError.new(408, "Presto API error due to timeout")
      raise @exception
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

    HTTP11_SEPARATOR = ["(", ")", "<", ">", "@", ",", ";", ":", "\\", "<", ">", "/", "[", "]", "?", "=", "{", "}", " ", "\v"]
    HTTP11_TOKEN_CHARSET = (32..126).map {|x| x.chr } - HTTP11_SEPARATOR
    HTTP11_TOKEN_REGEXP = /^[#{Regexp.escape(HTTP11_TOKEN_CHARSET.join)}]+\z/
    HTTP11_CTL_CHARSET = (0..31).map {|x| x.chr } + [127.chr]
    HTTP11_CTL_CHARSET_REGEXP = /[#{Regexp.escape(HTTP11_CTL_CHARSET.join)}]/

    def encode_properties(properties)
      # this is a hack to set same header multiple times.
      properties.map do |k, v|
        token = k.to_s
        field_value = v.to_s  # TODO LWS encoding is not implemented
        unless k =~ HTTP11_TOKEN_REGEXP
          raise Faraday::ClientError, "Key of properties can't include HTTP/1.1 control characters or separators (#{HTTP11_SEPARATOR.map {|c| c =~ /\s/ ? c.dump : c }.join(' ')})"
        end
        if field_value =~ HTTP11_CTL_CHARSET_REGEXP
          raise Faraday::ClientError, "Value of properties can't include HTTP/1.1 control characters"
        end
        "#{token}=#{field_value}"
      end.join("\r\n#{PrestoHeaders::PRESTO_SESSION}: ")
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

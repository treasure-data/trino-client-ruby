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

  require 'cgi'

  module PrestoHeaders
    PRESTO_USER = "X-Presto-User"
    PRESTO_SOURCE = "X-Presto-Source"
    PRESTO_CATALOG = "X-Presto-Catalog"
    PRESTO_SCHEMA = "X-Presto-Schema"
    PRESTO_TIME_ZONE = "X-Presto-Time-Zone"
    PRESTO_LANGUAGE = "X-Presto-Language"
    PRESTO_SESSION = "X-Presto-Session"
    PRESTO_CLIENT_INFO = "X-Presto-Client-Info";
    PRESTO_CLIENT_TAGS = "X-Presto-Client-Tags";

    PRESTO_CURRENT_STATE = "X-Presto-Current-State"
    PRESTO_MAX_WAIT = "X-Presto-Max-Wait"
    PRESTO_MAX_SIZE = "X-Presto-Max-Size"
    PRESTO_PAGE_SEQUENCE_ID = "X-Presto-Page-Sequence-Id"
  end

  HEADERS = {
    "User-Agent" => "presto-ruby/#{VERSION}",
  }

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
      if options[:user] && options[:password]
        faraday.basic_auth(options[:user], options[:password])
      end

      faraday.response :logger if options[:http_debug]
      faraday.adapter Faraday.default_adapter
    end

    faraday.headers.merge!(HEADERS)
    faraday.headers.merge!(optional_headers(options))

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

  def self.optional_headers(options)
    headers = {}
    if v = options[:user]
      headers[PrestoHeaders::PRESTO_USER] = v
    end
    if v = options[:source]
      headers[PrestoHeaders::PRESTO_SOURCE] = v
    end
    if v = options[:catalog]
      headers[PrestoHeaders::PRESTO_CATALOG] = v
    end
    if v = options[:schema]
      headers[PrestoHeaders::PRESTO_SCHEMA] = v
    end
    if v = options[:time_zone]
      headers[PrestoHeaders::PRESTO_TIME_ZONE] = v
    end
    if v = options[:language]
      headers[PrestoHeaders::PRESTO_LANGUAGE] = v
    end
    if v = options[:properties]
      headers[PrestoHeaders::PRESTO_SESSION] = encode_properties(v)
    end
    if v = options[:client_info]
      headers[PrestoHeaders::PRESTO_CLIENT_INFO] = encode_client_info(v)
    end
    if v = options[:client_tags]
      headers[PrestoHeaders::PRESTO_CLIENT_TAGS] = encode_client_tags(v)
    end
    if options[:enable_x_msgpack]
      # option name is enable_"x"_msgpack because "Accept: application/x-msgpack" header is
      # not officially supported by Presto. We can use this option only if a proxy server
      # decodes & encodes response body. Once this option is supported by Presto, option
      # name should be enable_msgpack, which might be slightly different behavior.
      headers['Accept'] = 'application/x-msgpack,application/json'
    end
    if v = options[:http_headers]
      headers.merge!(v)
    end
    headers
  end

  HTTP11_SEPARATOR = ["(", ")", "<", ">", "@", ",", ";", ":", "\\", "<", ">", "/", "[", "]", "?", "=", "{", "}", " ", "\v"]
  HTTP11_TOKEN_CHARSET = (32..126).map {|x| x.chr } - HTTP11_SEPARATOR
  HTTP11_TOKEN_REGEXP = /^[#{Regexp.escape(HTTP11_TOKEN_CHARSET.join)}]+\z/
  HTTP11_CTL_CHARSET = (0..31).map {|x| x.chr } + [127.chr]
  HTTP11_CTL_CHARSET_REGEXP = /[#{Regexp.escape(HTTP11_CTL_CHARSET.join)}]/

  def self.encode_properties(properties)
    properties.map do |k, v|
      token = k.to_s
      field_value = v.to_s  # TODO LWS encoding is not implemented
      unless k =~ HTTP11_TOKEN_REGEXP
        raise Faraday::ClientError, "Key of properties can't include HTTP/1.1 control characters or separators (#{HTTP11_SEPARATOR.map {|c| c =~ /\s/ ? c.dump : c }.join(' ')})"
      end
      if field_value =~ HTTP11_CTL_CHARSET_REGEXP
        raise Faraday::ClientError, "Value of properties can't include HTTP/1.1 control characters"
      end
      field_value = CGI.escape(field_value)
      "#{token}=#{field_value}"
    end
  end

  def self.encode_client_info(info)
    if info.is_a?(String)
      info
    else
      JSON.dump(info)
    end
  end

  def self.encode_client_tags(tags)
    Array(tags).join(",")
  end

  private_class_method :faraday_ssl_options, :optional_headers, :encode_properties, :encode_client_info, :encode_client_tags

end

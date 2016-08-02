require 'spec_helper'

describe Presto::Client::StatementClient do
  let :options do
    {
      server: "localhost",
      user: "frsyuki",
      catalog: "native",
      schema: "default",
      time_zone: "US/Pacific",
      language: "ja_JP",
      properties: {"hello" => "world", "name"=>"value"},
      debug: true,
    }
  end

  let :query do
    "select * from sys.node"
  end

  let :response_json do
    {
      id: "queryid",
      stats: {}
    }
  end

  it "sets headers" do
    stub_request(:post, "localhost/v1/statement").
      with(body: query,
           headers: {
              "User-Agent" => "presto-ruby/#{VERSION}",
              "X-Presto-Catalog" => options[:catalog],
              "X-Presto-Schema" => options[:schema],
              "X-Presto-User" => options[:user],
              "X-Presto-Language" => options[:language],
              "X-Presto-Time-Zone" => options[:time_zone],
              "X-Presto-Session" => options[:properties].map {|k,v| "#{k}=#{v}"}.join("\r\nX-Presto-Session: ")
    }).to_return(body: response_json.to_json)

    faraday = Faraday.new(url: "http://localhost")
    StatementClient.new(faraday, query, options)
  end

  let :response_json2 do
    {
      id: "queryid",
      nextUri: 'http://localhost/v1/next_uri',
      stats: {}
    }
  end

  it "sets headers" do
    retry_p = false
    stub_request(:post, "localhost/v1/statement").
      with(body: query,
           headers: {
              "User-Agent" => "presto-ruby/#{VERSION}",
              "X-Presto-Catalog" => options[:catalog],
              "X-Presto-Schema" => options[:schema],
              "X-Presto-User" => options[:user],
              "X-Presto-Language" => options[:language],
              "X-Presto-Time-Zone" => options[:time_zone],
              "X-Presto-Session" => options[:properties].map {|k,v| "#{k}=#{v}"}.join("\r\nX-Presto-Session: ")
    }).to_return(body: response_json2.to_json)

    stub_request(:get, "localhost/v1/next_uri").
      with(headers: {
              "User-Agent" => "presto-ruby/#{VERSION}",
              "X-Presto-Catalog" => options[:catalog],
              "X-Presto-Schema" => options[:schema],
              "X-Presto-User" => options[:user],
              "X-Presto-Language" => options[:language],
              "X-Presto-Time-Zone" => options[:time_zone],
              "X-Presto-Session" => options[:properties].map {|k,v| "#{k}=#{v}"}.join("\r\nX-Presto-Session: ")
    }).to_return(body: lambda{|req|if retry_p; response_json.to_json; else; retry_p=true; raise Timeout::Error.new("execution expired"); end })

    faraday = Faraday.new(url: "http://localhost")
    sc = StatementClient.new(faraday, query, options.merge(http_open_timeout: 1))
    sc.has_next?.should be_true
    sc.advance.should be_true
    retry_p.should be_true
  end

  it "decodes DeleteHandle" do
    dh = Models::DeleteHandle.decode({
      "handle" => {
        "connectorId" => "c1",
        "connectorHandle" => {},
      }
    })
    dh.handle.should be_a_kind_of Models::TableHandle
    dh.handle.connector_id.should == "c1"
    dh.handle.connector_handle.should == {}
  end

  it "validates models" do
    lambda do
      Models::DeleteHandle.decode({
        "handle" => "invalid"
      })
    end.should raise_error(TypeError, /String to Hash/)
  end
end


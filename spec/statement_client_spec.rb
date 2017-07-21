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

  it "uses 'Accept: application/x-msgpack' if option is set" do
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
              "X-Presto-Session" => options[:properties].map {|k,v| "#{k}=#{v}"}.join("\r\nX-Presto-Session: "),
              "Accept" => "application/x-msgpack,application/json"
    }).to_return(body: MessagePack.dump(response_json2), headers: {"Content-Type" => "application/x-msgpack"})

    stub_request(:get, "localhost/v1/next_uri").
      with(headers: {
              "User-Agent" => "presto-ruby/#{VERSION}",
              "X-Presto-Catalog" => options[:catalog],
              "X-Presto-Schema" => options[:schema],
              "X-Presto-User" => options[:user],
              "X-Presto-Language" => options[:language],
              "X-Presto-Time-Zone" => options[:time_zone],
              "X-Presto-Session" => options[:properties].map {|k,v| "#{k}=#{v}"}.join("\r\nX-Presto-Session: "),
              "Accept" => "application/x-msgpack,application/json"
    }).to_return(body: lambda{|req|if retry_p; MessagePack.dump(response_json); else; retry_p=true; raise Timeout::Error.new("execution expired"); end }, headers: {"Content-Type" => "application/x-msgpack"})

    faraday = Faraday.new(url: "http://localhost")
    sc = StatementClient.new(faraday, query, options.merge(http_open_timeout: 1, enable_x_msgpack: "application/x-msgpack"))
    sc.has_next?.should be_true
    sc.advance.should be_true
    retry_p.should be_true
  end

  it "decodes DeleteHandle" do
    dh = Models::DeleteHandle.decode({
      "handle" => {
        "connectorId" => "c1",
        "connectorHandle" => {}
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

  describe 'HTTP basic auth' do
    let(:password) { 'abcd' }

    it "adds basic auth headers when ssl is enabled and a password is given" do
      stub_request(:post, "https://localhost/v1/statement").
        with(body: query,
             headers: {
                "User-Agent" => "presto-ruby/#{VERSION}",
                "X-Presto-Catalog" => options[:catalog],
                "X-Presto-Schema" => options[:schema],
                "X-Presto-User" => options[:user],
                "X-Presto-Language" => options[:language],
                "X-Presto-Time-Zone" => options[:time_zone],
                "X-Presto-Session" => options[:properties].map {|k,v| "#{k}=#{v}"}.join("\r\nX-Presto-Session: ")
            },
            basic_auth: [options[:user], password]
      ).to_return(body: response_json.to_json)

      faraday = Query.__send__(:faraday_client, options.merge(ssl: { verify: true }, password: password))
      StatementClient.new(faraday, query, options)
    end

    it "forbids using basic auth when ssl is disabled" do
      lambda do
        Query.__send__(:faraday_client, {
          server: 'localhost',
          password: 'abcd'
        })
      end.should raise_error(ArgumentError)
    end
  end

  describe "ssl" do
    it "is disabled by default" do
      f = Query.__send__(:faraday_client, {
        server: "localhost",
      })
      f.url_prefix.to_s.should == "http://localhost/"
    end

    it "is enabled with ssl: true" do
      f = Query.__send__(:faraday_client, {
        server: "localhost",
        ssl: true,
      })
      f.url_prefix.to_s.should == "https://localhost/"
      f.ssl.verify?.should == true
    end

    it "is enabled with ssl: {verify: false}" do
      f = Query.__send__(:faraday_client, {
        server: "localhost",
        ssl: {verify: false}
      })
      f.url_prefix.to_s.should == "https://localhost/"
      f.ssl.verify?.should == false
    end

    it "rejects invalid ssl: verify: object" do
      lambda do
        f = Query.__send__(:faraday_client, {
          server: "localhost",
          ssl: {verify: "??"}
        })
      end.should raise_error(ArgumentError, /String/)
    end

    it "is enabled with ssl: Hash" do
      require 'openssl'

      ssl = {
        ca_file: "/path/to/dummy.pem",
        ca_path: "/path/to/pemdir",
        cert_store: OpenSSL::X509::Store.new,
        client_cert: OpenSSL::X509::Certificate.new,
        client_key: OpenSSL::PKey::DSA.new,
      }

      f = Query.__send__(:faraday_client, {
        server: "localhost",
        ssl: ssl,
      })

      f.url_prefix.to_s.should == "https://localhost/"
      f.ssl.verify?.should == true
      f.ssl.ca_file.should == ssl[:ca_file]
      f.ssl.ca_path.should == ssl[:ca_path]
      f.ssl.cert_store.should == ssl[:cert_store]
      f.ssl.client_cert.should == ssl[:client_cert]
      f.ssl.client_key.should == ssl[:client_key]
    end

    it "rejects an invalid string" do
      lambda do
        Query.__send__(:faraday_client, {
          server: "localhost",
          ssl: '??',
        })
      end.should raise_error(ArgumentError, /String/)
    end

    it "rejects an integer" do
      lambda do
        Query.__send__(:faraday_client, {
          server: "localhost",
          ssl: 3,
        })
      end.should raise_error(ArgumentError, /:ssl/)
    end
  end

  it "supports multiple model versions" do
    stub_request(:post, "localhost/v1/statement").
      with({body: query}).
      to_return(body: response_json.to_json)

    faraday = Faraday.new(url: "http://localhost")
    client = StatementClient.new(faraday, query, options.merge(model_version: "0.149"))
    client.current_results.should be_a_kind_of(ModelVersions::V0_149::QueryResults)
  end

  it "rejects unsupported model version" do
    lambda do
      StatementClient.new(faraday, query, options.merge(model_version: "0.111"))
    end.should raise_error(NameError)
  end
end


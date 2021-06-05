require 'spec_helper'

describe Trino::Client::StatementClient do
  let :options do
    {
      server: "localhost",
      user: "frsyuki",
      catalog: "native",
      schema: "default",
      time_zone: "US/Pacific",
      language: "ja_JP",
      debug: true,
      follow_redirect: true
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

  let :faraday do
    Trino::Client.faraday_client(options)
  end

  it "sets headers" do
    stub_request(:post, "localhost/v1/statement").
      with(body: query,
           headers: {
              "User-Agent" => "trino-ruby/#{VERSION}",
              "X-Trino-Catalog" => options[:catalog],
              "X-Trino-Schema" => options[:schema],
              "X-Trino-User" => options[:user],
              "X-Trino-Language" => options[:language],
              "X-Trino-Time-Zone" => options[:time_zone],
    }).to_return(body: response_json.to_json)

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
              "User-Agent" => "trino-ruby/#{VERSION}",
              "X-Trino-Catalog" => options[:catalog],
              "X-Trino-Schema" => options[:schema],
              "X-Trino-User" => options[:user],
              "X-Trino-Language" => options[:language],
              "X-Trino-Time-Zone" => options[:time_zone],
    }).to_return(body: response_json2.to_json)

    stub_request(:get, "localhost/v1/next_uri").
      with(headers: {
              "User-Agent" => "trino-ruby/#{VERSION}",
              "X-Trino-Catalog" => options[:catalog],
              "X-Trino-Schema" => options[:schema],
              "X-Trino-User" => options[:user],
              "X-Trino-Language" => options[:language],
              "X-Trino-Time-Zone" => options[:time_zone],
    }).to_return(body: lambda{|req|if retry_p; response_json.to_json; else; retry_p=true; raise Timeout::Error.new("execution expired"); end })

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
              "User-Agent" => "trino-ruby/#{VERSION}",
              "X-Trino-Catalog" => options[:catalog],
              "X-Trino-Schema" => options[:schema],
              "X-Trino-User" => options[:user],
              "X-Trino-Language" => options[:language],
              "X-Trino-Time-Zone" => options[:time_zone],
              "Accept" => "application/x-msgpack,application/json"
    }).to_return(body: MessagePack.dump(response_json2), headers: {"Content-Type" => "application/x-msgpack"})

    stub_request(:get, "localhost/v1/next_uri").
      with(headers: {
              "User-Agent" => "trino-ruby/#{VERSION}",
              "X-Trino-Catalog" => options[:catalog],
              "X-Trino-Schema" => options[:schema],
              "X-Trino-User" => options[:user],
              "X-Trino-Language" => options[:language],
              "X-Trino-Time-Zone" => options[:time_zone],
              "Accept" => "application/x-msgpack,application/json"
    }).to_return(body: lambda{|req|if retry_p; MessagePack.dump(response_json); else; retry_p=true; raise Timeout::Error.new("execution expired"); end }, headers: {"Content-Type" => "application/x-msgpack"})

    options.merge!(http_open_timeout: 1, enable_x_msgpack: "application/x-msgpack")
    sc = StatementClient.new(faraday, query, options)
    sc.has_next?.should be_true
    sc.advance.should be_true
    retry_p.should be_true
  end

  # trino version could be "V0_ddd" or "Vddd"
  /\Trino::Client::ModelVersions::V(\w+)/ =~ Trino::Client::Models.to_s

  # https://github.com/prestosql/presto/commit/80a2c5113d47e3390bf6dc041486a1c9dfc04592
  # renamed DeleteHandle to DeleteTarget, then DeleteHandle exists when trino version
  # is less than 313.
  if $1[0, 2] == "0_" || $1.to_i < 314
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
  else
    it "decodes DeleteTarget" do
      dh = Models::DeleteTarget.decode({
        "handle" => {
          "catalogName" => "c1",
          "connectorHandle" => {}
        }
      })
      dh.handle.should be_a_kind_of Models::TableHandle
      dh.handle.catalog_name.should == "c1"
      dh.handle.connector_handle.should == {}
    end

    it "validates models" do
      lambda do
        Models::DeleteTarget.decode({
          "catalogName" => "c1",
          "handle" => "invalid"
        })
      end.should raise_error(TypeError, /String to Hash/)
    end
  end

  it "receives headers of POST" do
    stub_request(:post, "localhost/v1/statement").
      with(body: query).to_return(body: response_json2.to_json, headers: {"X-Test-Header" => "123"})

    sc = StatementClient.new(faraday, query, options.merge(http_open_timeout: 1))
    sc.current_results_headers["X-Test-Header"].should == "123"
  end

  it "receives headers of POST through Query" do
    stub_request(:post, "localhost/v1/statement").
      with(body: query).to_return(body: response_json2.to_json, headers: {"X-Test-Header" => "123"})

    q = Trino::Client.new(options).query(query)
    q.current_results_headers["X-Test-Header"].should == "123"
  end

  describe "#query_id" do
    it "returns query_id" do
      stub_request(:post, "localhost/v1/statement").
        with(body: query).to_return(body: response_json2.to_json, headers: {"X-Test-Header" => "123"})

     stub_request(:get, "localhost/v1/next_uri").
        to_return(body: response_json.to_json, headers: {"X-Test-Header" => "123"})

      sc = StatementClient.new(faraday, query, options.merge(http_open_timeout: 1))
      sc.query_id.should == "queryid"
      sc.has_next?.should be_true
      sc.advance.should be_true
      sc.query_id.should == "queryid"
    end
  end

  describe '#query_info' do
    let :headers do
      {
        "User-Agent" => "trino-ruby/#{VERSION}",
        "X-Trino-Catalog" => options[:catalog],
          "X-Trino-Schema" => options[:schema],
          "X-Trino-User" => options[:user],
          "X-Trino-Language" => options[:language],
          "X-Trino-Time-Zone" => options[:time_zone],
      }
    end

    let :statement_client do
      stub_request(:post, "http://localhost/v1/statement").
        with(body: query, headers: headers).
        to_return(body: response_json2.to_json)
      StatementClient.new(faraday, query, options)
    end

    it "raises an exception with sample JSON if response is unexpected" do
      lambda do
        stub_request(:get, "http://localhost/v1/query/#{response_json2[:id]}").
          with(headers: headers).
          to_return(body: {"session" => "invalid session structure"}.to_json)
        statement_client.query_info
      end.should raise_error(TrinoHttpError, /Trino API returned unexpected structure at \/v1\/query\/queryid\. Expected Trino::Client::ModelVersions::.*::QueryInfo but got {"session":"invalid session structure"}/)
    end

    it "raises an exception if response format is unexpected" do
      lambda do
        stub_request(:get, "http://localhost/v1/query/#{response_json2[:id]}").
          with(headers: headers).
          to_return(body: "unexpected data structure (not JSON)")
        statement_client.query_info
      end.should raise_error(TrinoHttpError, /Trino API returned unexpected data format./)
    end

    it "is redirected if server returned 301" do
      stub_request(:get, "http://localhost/v1/query/#{response_json2[:id]}").
        with(headers: headers).
        to_return(status: 301, headers: {"Location" => "http://localhost/v1/query/redirected"})

      stub_request(:get, "http://localhost/v1/query/redirected").
        with(headers: headers).
        to_return(body: {"queryId" => "queryid"}.to_json)

      query_info = statement_client.query_info
      query_info.query_id.should == "queryid"
    end
  end

  describe "Killing a query" do
    let(:query_id) { 'A_QUERY_ID' }

    it "sends DELETE request with empty body to /v1/query/{queryId}" do
      stub_request(:delete, "http://localhost/v1/query/#{query_id}").
        with(body: "",
             headers: {
                "User-Agent" => "trino-ruby/#{VERSION}",
                "X-Trino-Catalog" => options[:catalog],
                "X-Trino-Schema" => options[:schema],
                "X-Trino-User" => options[:user],
                "X-Trino-Language" => options[:language],
                "X-Trino-Time-Zone" => options[:time_zone],
      }).to_return(body: {}.to_json)

      Trino::Client.new(options).kill(query_id)
    end
  end

  describe 'advanced HTTP headers' do
    let(:headers) do
      {
        "User-Agent" => "trino-ruby/#{VERSION}",
        "X-Trino-Catalog" => options[:catalog],
        "X-Trino-Schema" => options[:schema],
        "X-Trino-User" => options[:user],
        "X-Trino-Language" => options[:language],
        "X-Trino-Time-Zone" => options[:time_zone],
      }
    end

    it "sets X-Trino-Session from properties" do
      options[:properties] = {"hello" => "world", "name"=>"value"}

      stub_request(:post, "localhost/v1/statement").
        with(body: query,
             headers: headers.merge({
               "X-Trino-Session" => options[:properties].map {|k,v| "#{k}=#{v}"}.join(", ")
             })).
        to_return(body: response_json.to_json)

      StatementClient.new(faraday, query, options)
    end

    it "sets X-Trino-Client-Info from client_info" do
      options[:client_info] = "raw"

      stub_request(:post, "localhost/v1/statement").
        with(body: query,
             headers: headers.merge("X-Trino-Client-Info" => "raw")).
        to_return(body: response_json.to_json)

      StatementClient.new(faraday, query, options)
    end

    it "sets X-Trino-Client-Info in JSON from client_info" do
      options[:client_info] = {"k1" => "v1", "k2" => "v2"}

      stub_request(:post, "localhost/v1/statement").
        with(body: query,
             headers: headers.merge("X-Trino-Client-Info" => '{"k1":"v1","k2":"v2"}')).
        to_return(body: response_json.to_json)

      StatementClient.new(faraday, query, options)
    end

    it "sets X-Trino-Client-Tags" do
      options[:client_tags] = ["k1:v1", "k2:v2"]

      stub_request(:post, "localhost/v1/statement").
        with(body: query,
             headers: headers.merge("X-Trino-Client-Tags" => "k1:v1,k2:v2")).
        to_return(body: response_json.to_json)

      StatementClient.new(faraday, query, options)
    end
  end

  describe 'HTTP basic auth' do
    let(:password) { 'abcd' }

    it "adds basic auth headers when ssl is enabled and a password is given" do
      stub_request(:post, "https://localhost/v1/statement").
        with(body: query,
             headers: {
                "User-Agent" => "trino-ruby/#{VERSION}",
                "X-Trino-Catalog" => options[:catalog],
                "X-Trino-Schema" => options[:schema],
                "X-Trino-User" => options[:user],
                "X-Trino-Language" => options[:language],
                "X-Trino-Time-Zone" => options[:time_zone],
            },
            basic_auth: [options[:user], password]
      ).to_return(body: response_json.to_json)

      options.merge!(ssl: { verify: true }, password: password)
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

  it "supports Presto" do
    stub_request(:post, "localhost/v1/statement").
      with({body: query}).
      to_return(body: response_json.to_json)

    faraday = Faraday.new(url: "http://localhost")
    client = StatementClient.new(faraday, query, options.merge(model_version: "316"))
    client.current_results.should be_a_kind_of(ModelVersions::V316::QueryResults)
  end

  it "rejects unsupported model version" do
    lambda do
      StatementClient.new(faraday, query, options.merge(model_version: "0.111"))
    end.should raise_error(NameError)
  end


  let :nested_json do
    nested_stats = {createTime: Time.now}
    # JSON max nesting default value is 100
    for i in 0..100 do
      nested_stats = {stats: nested_stats}
    end
    {
        id: "queryid",
        stats: nested_stats
    }
  end

  it "parse nested json properly" do
    stub_request(:post, "localhost/v1/statement").
        with(body: query,
             headers: {
                 "User-Agent" => "trino-ruby/#{VERSION}",
                 "X-Trino-Catalog" => options[:catalog],
                 "X-Trino-Schema" => options[:schema],
                 "X-Trino-User" => options[:user],
                 "X-Trino-Language" => options[:language],
                 "X-Trino-Time-Zone" => options[:time_zone],
             }).to_return(body: nested_json.to_json(:max_nesting => false))

    StatementClient.new(faraday, query, options)
  end

  describe "query timeout" do
    let :headers do
      {
        "User-Agent" => "trino-ruby/#{VERSION}",
        "X-Trino-Catalog" => options[:catalog],
        "X-Trino-Schema" => options[:schema],
        "X-Trino-User" => options[:user],
        "X-Trino-Language" => options[:language],
        "X-Trino-Time-Zone" => options[:time_zone],
      }
    end

    let :planning_response do
      {
        id: "queryid",
        nextUri: 'http://localhost/v1/next_uri',
        stats: {},
      }
    end

    let :early_running_response do
      {
        id: "queryid",
        nextUri: 'http://localhost/v1/next_uri',
        stats: {},
        columns: [{name: "_col0", type: "bigint"}],
      }
    end

    let :late_running_response do
      {
        id: "queryid",
        nextUri: 'http://localhost/v1/next_uri',
        stats: {},
        columns: [{name: "_col0", type: "bigint"}],
        data: "",
      }
    end

    let :done_response do
      {
        id: "queryid",
        stats: {},
        columns: [{name: "_col0", type: "bigint"}],
      }
    end

    before(:each) do
    end

    [:plan_timeout, :query_timeout].each do |timeout_type|
      it "raises TrinoQueryTimeoutError if timeout during planning" do
        stub_request(:post, "localhost/v1/statement").
          with(body: query, headers: headers).
          to_return(body: planning_response.to_json)

        client = StatementClient.new(faraday, query, options.merge(timeout_type => 1))

        stub_request(:get, "localhost/v1/next_uri").
          with(headers: headers).
          to_return(body: planning_response.to_json)
        client.advance

        sleep 1
        stub_request(:get, "localhost/v1/next_uri").
          with(headers: headers).
          to_return(body: planning_response.to_json)
        lambda do
          client.advance
        end.should raise_error(Trino::Client::TrinoQueryTimeoutError, "Query queryid timed out")
      end

      it "raises TrinoQueryTimeoutError if timeout during initial resuming" do
        stub_request(:get, "localhost/v1/next_uri").
          with(headers: headers).
          to_return(body: lambda{|req| raise Timeout::Error.new("execution expired")})

        lambda do
          StatementClient.new(faraday, query, options.merge(timeout_type => 1), "/v1/next_uri")
        end.should raise_error(Trino::Client::TrinoQueryTimeoutError, "Query timed out")
      end

      it "raises TrinoHttpError if timeout during initial resuming and #{timeout_type} < retry_timeout" do
        stub_request(:get, "localhost/v1/next_uri").
          with(headers: headers).
          to_return(body: lambda{|req| raise Timeout::Error.new("execution expired")})

        lambda do
          StatementClient.new(faraday, query, options.merge(timeout_type => 2, retry_timeout: 1), "/v1/next_uri")
        end.should raise_error(Trino::Client::TrinoHttpError, "Trino API error due to timeout")
      end
    end

    it "doesn't raise errors with plan_timeout if query planning is done" do
      stub_request(:post, "localhost/v1/statement").
        with(body: query, headers: headers).
        to_return(body: planning_response.to_json)

      client = StatementClient.new(faraday, query, options.merge(plan_timeout: 1))

      sleep 1

      stub_request(:get, "localhost/v1/next_uri").
        with(headers: headers).
        to_return(body: early_running_response.to_json)
      client.advance

      stub_request(:get, "localhost/v1/next_uri").
        with(headers: headers).
        to_return(body: late_running_response.to_json)
      client.advance
    end

    it "raises TrinoQueryTimeoutError if timeout during execution" do
      stub_request(:post, "localhost/v1/statement").
        with(body: query, headers: headers).
        to_return(body: planning_response.to_json)

      client = StatementClient.new(faraday, query, options.merge(query_timeout: 1))

      stub_request(:get, "localhost/v1/next_uri").
        with(headers: headers).
        to_return(body: early_running_response.to_json)
      client.advance

      sleep 1
      stub_request(:get, "localhost/v1/next_uri").
        with(headers: headers).
        to_return(body: late_running_response.to_json)
      lambda do
        client.advance
      end.should raise_error(Trino::Client::TrinoQueryTimeoutError, "Query queryid timed out")
    end

    it "doesn't raise errors if query is done" do
      stub_request(:post, "localhost/v1/statement").
        with(body: query, headers: headers).
        to_return(body: planning_response.to_json)

      client = StatementClient.new(faraday, query, options.merge(query_timeout: 1))

      stub_request(:get, "localhost/v1/next_uri").
        with(headers: headers).
        to_return(body: early_running_response.to_json)
      client.advance

      stub_request(:get, "localhost/v1/next_uri").
        with(headers: headers).
        to_return(body: done_response.to_json)
      client.advance # set finished

      sleep 1
      client.advance # set finished
    end

  end
end


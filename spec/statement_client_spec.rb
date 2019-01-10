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

  let :faraday do
    Presto::Client.faraday_client(options)
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
    }).to_return(body: response_json.to_json)

    StatementClient.new(faraday, query, options)
  end

  it "returns results correctly" do
    query = 'select 1 as i, 1.0 as d'
    stub_request(:post, "localhost/v1/statement").
      with(body: query,
           headers: {
              "User-Agent" => "presto-ruby/#{VERSION}",
              "X-Presto-Catalog" => options[:catalog],
              "X-Presto-Schema" => options[:schema],
              "X-Presto-User" => options[:user],
              "X-Presto-Language" => options[:language],
              "X-Presto-Time-Zone" => options[:time_zone],
    }).to_return(body: <<-JSON)
      {"id":"queryid","infoUri":"http://localhost/ui/query.html?queryid","nextUri":"http://localhost/v1/statement/queryid/1","stats":{"state":"QUEUED","queued":true,"scheduled":false,"nodes":0,"totalSplits":0,"queuedSplits":0,"runningSplits":0,"completedSplits":0,"userTimeMillis":0,"cpuTimeMillis":0,"wallTimeMillis":0,"queuedTimeMillis":0,"elapsedTimeMillis":0,"processedRows":0,"processedBytes":0,"peakMemoryBytes":0}}
    JSON
    client = StatementClient.new(faraday, query, options)
    client.current_results.data.should be_nil

    stub_request(:get, "http://localhost/v1/statement/queryid/1").to_return(body: <<-JSON)
      {"id":"queryid","infoUri":"http://localhost/ui/query.html?queryid","partialCancelUri":"http://192.168.128.77:8091/v1/stage/queryid.0","nextUri":"http://localhost/v1/statement/queryid/2","columns":[{"name":"i","type":"integer","typeSignature":{"rawType":"integer","typeArguments":[],"literalArguments":[],"arguments":[]}},{"name":"d","type":"decimal(2,1)","typeSignature":{"rawType":"decimal","typeArguments":[],"literalArguments":[],"arguments":[{"kind":"LONG_LITERAL","value":2},{"kind":"LONG_LITERAL","value":1}]}}],"data":[[1,"1.0"]],"stats":{"state":"RUNNING","queued":false,"scheduled":true,"nodes":1,"totalSplits":17,"queuedSplits":17,"runningSplits":0,"completedSplits":0,"userTimeMillis":0,"cpuTimeMillis":0,"wallTimeMillis":0,"queuedTimeMillis":1,"elapsedTimeMillis":121,"processedRows":0,"processedBytes":0,"peakMemoryBytes":0,"rootStage":{"stageId":"0","state":"RUNNING","done":false,"nodes":1,"totalSplits":17,"queuedSplits":17,"runningSplits":0,"completedSplits":0,"userTimeMillis":0,"cpuTimeMillis":0,"wallTimeMillis":0,"processedRows":0,"processedBytes":0,"subStages":[]},"progressPercentage":0.0}}
    JSON
    client.advance.should be_true
    client.current_results.data.should == [[1, BigDecimal('1.0')]]

    stub_request(:get, "http://localhost/v1/statement/queryid/2").to_return(body: <<-JSON)
      {"id":"queryid","infoUri":"http://localhost/ui/query.html?queryid","columns":[{"name":"i","type":"integer","typeSignature":{"rawType":"integer","typeArguments":[],"literalArguments":[],"arguments":[]}},{"name":"d","type":"decimal(2,1)","typeSignature":{"rawType":"decimal","typeArguments":[],"literalArguments":[],"arguments":[{"kind":"LONG_LITERAL","value":2},{"kind":"LONG_LITERAL","value":1}]}}],"stats":{"state":"FINISHED","queued":false,"scheduled":true,"nodes":1,"totalSplits":17,"queuedSplits":0,"runningSplits":0,"completedSplits":17,"userTimeMillis":4,"cpuTimeMillis":5,"wallTimeMillis":109,"queuedTimeMillis":1,"elapsedTimeMillis":128,"processedRows":0,"processedBytes":0,"peakMemoryBytes":0,"rootStage":{"stageId":"0","state":"FINISHED","done":true,"nodes":1,"totalSplits":17,"queuedSplits":0,"runningSplits":0,"completedSplits":17,"userTimeMillis":4,"cpuTimeMillis":5,"wallTimeMillis":109,"processedRows":1,"processedBytes":0,"subStages":[]},"progressPercentage":100.0}}
    JSON
    client.advance.should be_true
    client.current_results.data.should be_nil
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
    }).to_return(body: response_json2.to_json)

    stub_request(:get, "localhost/v1/next_uri").
      with(headers: {
              "User-Agent" => "presto-ruby/#{VERSION}",
              "X-Presto-Catalog" => options[:catalog],
              "X-Presto-Schema" => options[:schema],
              "X-Presto-User" => options[:user],
              "X-Presto-Language" => options[:language],
              "X-Presto-Time-Zone" => options[:time_zone],
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
              "User-Agent" => "presto-ruby/#{VERSION}",
              "X-Presto-Catalog" => options[:catalog],
              "X-Presto-Schema" => options[:schema],
              "X-Presto-User" => options[:user],
              "X-Presto-Language" => options[:language],
              "X-Presto-Time-Zone" => options[:time_zone],
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
              "Accept" => "application/x-msgpack,application/json"
    }).to_return(body: lambda{|req|if retry_p; MessagePack.dump(response_json); else; retry_p=true; raise Timeout::Error.new("execution expired"); end }, headers: {"Content-Type" => "application/x-msgpack"})

    options.merge!(http_open_timeout: 1, enable_x_msgpack: "application/x-msgpack")
    sc = StatementClient.new(faraday, query, options)
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

  describe '#query_info' do
    let :headers do
      {
        "User-Agent" => "presto-ruby/#{VERSION}",
        "X-Presto-Catalog" => options[:catalog],
          "X-Presto-Schema" => options[:schema],
          "X-Presto-User" => options[:user],
          "X-Presto-Language" => options[:language],
          "X-Presto-Time-Zone" => options[:time_zone],
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
      end.should raise_error(PrestoHttpError, /Presto API returned unexpected structure at \/v1\/query\/queryid\. Expected Presto::Client::ModelVersions::.*::QueryInfo but got {"session":"invalid session structure"}/)
    end

    it "raises an exception if response format is unexpected" do
      lambda do
        stub_request(:get, "http://localhost/v1/query/#{response_json2[:id]}").
          with(headers: headers).
          to_return(body: "unexpected data structure (not JSON)")
        statement_client.query_info
      end.should raise_error(PrestoHttpError, /Presto API returned unexpected data format./)
    end
  end

  describe "Killing a query" do
    let(:query_id) { 'A_QUERY_ID' }

    it "sends DELETE request with empty body to /v1/query/{queryId}" do
      stub_request(:delete, "http://localhost/v1/query/#{query_id}").
        with(body: "",
             headers: {
                "User-Agent" => "presto-ruby/#{VERSION}",
                "X-Presto-Catalog" => options[:catalog],
                "X-Presto-Schema" => options[:schema],
                "X-Presto-User" => options[:user],
                "X-Presto-Language" => options[:language],
                "X-Presto-Time-Zone" => options[:time_zone],
      }).to_return(body: {}.to_json)

      Presto::Client.new(options).kill(query_id)
    end
  end

  describe 'advanced HTTP headers' do
    let(:headers) do
      {
        "User-Agent" => "presto-ruby/#{VERSION}",
        "X-Presto-Catalog" => options[:catalog],
        "X-Presto-Schema" => options[:schema],
        "X-Presto-User" => options[:user],
        "X-Presto-Language" => options[:language],
        "X-Presto-Time-Zone" => options[:time_zone],
      }
    end

    it "sets X-Presto-Session from properties" do
      options[:properties] = {"hello" => "world", "name"=>"value"}

      stub_request(:post, "localhost/v1/statement").
        with(body: query,
             headers: headers.merge({
               "X-Presto-Session" => options[:properties].map {|k,v| "#{k}=#{v}"}.join(", ")
             })).
        to_return(body: response_json.to_json)

      StatementClient.new(faraday, query, options)
    end

    it "sets X-Presto-Client-Info from client_info" do
      options[:client_info] = "raw"

      stub_request(:post, "localhost/v1/statement").
        with(body: query,
             headers: headers.merge("X-Presto-Client-Info" => "raw")).
        to_return(body: response_json.to_json)

      StatementClient.new(faraday, query, options)
    end

    it "sets X-Presto-Client-Info in JSON from client_info" do
      options[:client_info] = {"k1" => "v1", "k2" => "v2"}

      stub_request(:post, "localhost/v1/statement").
        with(body: query,
             headers: headers.merge("X-Presto-Client-Info" => '{"k1":"v1","k2":"v2"}')).
        to_return(body: response_json.to_json)

      StatementClient.new(faraday, query, options)
    end

    it "sets X-Presto-Client-Tags" do
      options[:client_tags] = ["k1:v1", "k2:v2"]

      stub_request(:post, "localhost/v1/statement").
        with(body: query,
             headers: headers.merge("X-Presto-Client-Tags" => "k1:v1,k2:v2")).
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
                "User-Agent" => "presto-ruby/#{VERSION}",
                "X-Presto-Catalog" => options[:catalog],
                "X-Presto-Schema" => options[:schema],
                "X-Presto-User" => options[:user],
                "X-Presto-Language" => options[:language],
                "X-Presto-Time-Zone" => options[:time_zone],
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
                 "User-Agent" => "presto-ruby/#{VERSION}",
                 "X-Presto-Catalog" => options[:catalog],
                 "X-Presto-Schema" => options[:schema],
                 "X-Presto-User" => options[:user],
                 "X-Presto-Language" => options[:language],
                 "X-Presto-Time-Zone" => options[:time_zone],
             }).to_return(body: nested_json.to_json(:max_nesting => false))

    StatementClient.new(faraday, query, options)
  end

  describe "query timeout" do
    let :headers do
      {
        "User-Agent" => "presto-ruby/#{VERSION}",
        "X-Presto-Catalog" => options[:catalog],
        "X-Presto-Schema" => options[:schema],
        "X-Presto-User" => options[:user],
        "X-Presto-Language" => options[:language],
        "X-Presto-Time-Zone" => options[:time_zone],
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
      it "raises PrestoQueryTimeoutError if timeout during planning" do
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
        end.should raise_error(Presto::Client::PrestoQueryTimeoutError, "Query queryid timed out")
      end

      it "raises PrestoQueryTimeoutError if timeout during initial resuming" do
        stub_request(:get, "localhost/v1/next_uri").
          with(headers: headers).
          to_return(body: lambda{|req| raise Timeout::Error.new("execution expired")})

        lambda do
          StatementClient.new(faraday, query, options.merge(timeout_type => 1), "/v1/next_uri")
        end.should raise_error(Presto::Client::PrestoQueryTimeoutError, "Query timed out")
      end

      it "raises PrestoHttpError if timeout during initial resuming and #{timeout_type} < retry_timeout" do
        stub_request(:get, "localhost/v1/next_uri").
          with(headers: headers).
          to_return(body: lambda{|req| raise Timeout::Error.new("execution expired")})

        lambda do
          StatementClient.new(faraday, query, options.merge(timeout_type => 2, retry_timeout: 1), "/v1/next_uri")
        end.should raise_error(Presto::Client::PrestoHttpError, "Presto API error due to timeout")
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

    it "raises PrestoQueryTimeoutError if timeout during execution" do
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
      end.should raise_error(Presto::Client::PrestoQueryTimeoutError, "Query queryid timed out")
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

      sleep 1
      stub_request(:get, "localhost/v1/next_uri").
        with(headers: headers).
        to_return(body: done_response.to_json)
      client.advance
    end

  end
end

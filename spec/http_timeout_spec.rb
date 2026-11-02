require "spec_helper"
require "faraday/adapter/test"

describe "HTTP request timeouts" do
  let(:options) { {server: "localhost"} }
  let(:requests) { [] }
  let(:next_uri) { "http://localhost/v1/next_uri" }
  let(:response_body) do
    {
      id: "queryid",
      nextUri: next_uri,
      partialCancelUri: "http://localhost/v1/cancel_uri",
      stats: {}
    }.to_json
  end

  let(:faraday) do
    Trino::Client.faraday_client(options).tap do |connection|
      connection.adapter :test do |stubs|
        [:post, :get, :delete].each do |method|
          stubs.public_send(method, /./) do |env|
            requests << [env.method, env.url.path, env.request.timeout, env.request.open_timeout]
            body = (env.url.path == "/v1/query/queryid") ? {queryId: "queryid"}.to_json : response_body
            [200, {}, body]
          end
        end
      end
    end
  end

  [
    ["default timeouts", {}, 300, 60],
    ["short timeouts", {http_timeout: 5, http_open_timeout: 2}, 5, 2],
    ["long timeouts", {http_timeout: 600, http_open_timeout: 120}, 600, 120],
    ["zero timeouts", {http_timeout: 0, http_open_timeout: 0}, 0, 0]
  ].each do |name, settings, timeout, open_timeout|
    it "uses #{name} for every request" do
      options.merge!(settings)
      query = Trino::Client::Query.start("SELECT 1", options, faraday)
      query.advance
      query.query_info
      query.cancel
      query.close
      Trino::Client::Query.kill("queryid", options, faraday)
      Trino::Client::Query.resume(next_uri, options, faraday)

      expect(requests).to eq([
        [:post, "/v1/statement", timeout, open_timeout],
        [:get, "/v1/next_uri", timeout, open_timeout],
        [:get, "/v1/query/queryid", timeout, open_timeout],
        [:delete, "/v1/cancel_uri", timeout, open_timeout],
        [:delete, "/v1/next_uri", timeout, open_timeout],
        [:delete, "/v1/query/queryid", timeout, open_timeout],
        [:get, "/v1/next_uri", timeout, open_timeout]
      ])
    end
  end

  it "uses updated timeouts when reusing a connection" do
    options.merge!(http_timeout: 5, http_open_timeout: 2)
    query = Trino::Client::Query.start("SELECT 1", options, faraday)
    options.merge!(http_timeout: 600, http_open_timeout: 120)
    query.advance
    query.close
    Trino::Client::Query.start("SELECT 2", options, faraday)
    Trino::Client::Query.kill("queryid", options, faraday)

    expect(requests).to eq([
      [:post, "/v1/statement", 5, 2],
      [:get, "/v1/next_uri", 600, 120],
      [:delete, "/v1/next_uri", 600, 120],
      [:post, "/v1/statement", 600, 120],
      [:delete, "/v1/query/queryid", 600, 120]
    ])
  end

  it "applies HTTP timeouts when closing an expired query" do
    options.merge!(http_timeout: 5, http_open_timeout: 2, query_timeout: 1)
    allow(Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(0)
    query = Trino::Client::Query.start("SELECT 1", options, faraday)
    allow(Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(2)

    expect { query.advance }.to raise_error(Trino::Client::TrinoQueryTimeoutError)
    expect(requests.last).to eq([:delete, "/v1/next_uri", 5, 2])
  end
end

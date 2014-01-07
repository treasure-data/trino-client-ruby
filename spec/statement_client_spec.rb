require 'spec_helper'

describe Presto::Client::StatementClient do
  let :session do
    session = ClientSession.new(
      server: "localhost",
      user: "frsyuki",
      catalog: "native",
      schema: "default",
      debug: true,
    )
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

  it do
    stub_request(:post, "localhost/v1/statement").
      with(body: query,
           headers: {
              "User-Agent" => "presto-ruby/#{VERSION}",
              "X-Presto-Catalog" => session.catalog,
              "X-Presto-Schema" => session.schema,
              "X-Presto-User" => session.user,
    }).to_return(body: response_json.to_json)

    faraday = Faraday.new(url: "http://localhost")
    StatementClient.new(faraday, session, query)
  end
end


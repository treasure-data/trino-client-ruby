require "spec_helper"
require "base64"

describe "Basic Auth with a reused Faraday connection" do
  let(:options) do
    {
      server: "localhost:8080",
      user: "test-user"
    }
  end

  let(:response_body) do
    {id: "query-id", stats: {}}.to_json
  end

  let(:https_error_message) do
    "Protocol must be https when passing a password"
  end

  it "rejects a password added after HTTP client initialization" do
    client = Trino::Client.new(options)
    options[:password] = "secret"

    request = stub_request(
      :post,
      "http://localhost:8080/v1/statement"
    ).to_return(body: response_body)

    expect {
      client.query("SELECT 1")
    }.to raise_error(ArgumentError, https_error_message)

    expect(request).not_to have_been_requested
  end

  it "checks the connection scheme rather than the updated ssl option" do
    client = Trino::Client.new(options)

    options[:password] = "secret"
    options[:ssl] = true

    request = stub_request(
      :post,
      "http://localhost:8080/v1/statement"
    ).to_return(body: response_body)

    expect {
      client.query("SELECT 1")
    }.to raise_error(ArgumentError, https_error_message)

    expect(request).not_to have_been_requested
  end

  it "rejects resuming a query after a password is added to an HTTP client" do
    client = Trino::Client.new(options)
    options[:password] = "secret"

    next_uri = "http://localhost:8080/v1/statement/next"

    request = stub_request(
      :get,
      next_uri
    ).to_return(body: response_body)

    expect {
      client.resume_query(next_uri)
    }.to raise_error(ArgumentError, https_error_message)

    expect(request).not_to have_been_requested
  end

  it "rejects killing a query after a password is added to an HTTP client" do
    client = Trino::Client.new(options)
    options[:password] = "secret"

    request = stub_request(
      :delete,
      "http://localhost:8080/v1/query/query-id"
    ).to_return(status: 204)

    expect {
      client.kill("query-id")
    }.to raise_error(ArgumentError, https_error_message)

    expect(request).not_to have_been_requested
  end

  it "uses the updated password after client initialization" do
    options[:ssl] = true
    options[:password] = "original-password"

    client = Trino::Client.new(options)

    options[:password] = "updated-password"

    authorization = "Basic " + Base64.strict_encode64(
      "test-user:updated-password"
    )

    request = stub_request(
      :post,
      "https://localhost:8080/v1/statement"
    ).with(
      body: "SELECT 1",
      headers: {"Authorization" => authorization}
    ).to_return(body: response_body)

    client.query("SELECT 1")

    expect(request).to have_been_requested.once
  end

  it "allows queries without a password on an HTTP connection" do
    client = Trino::Client.new(options)

    request = stub_request(
      :post,
      "http://localhost:8080/v1/statement"
    ).with { |req|
      !req.headers.key?("Authorization")
    }.to_return(body: response_body)

    client.query("SELECT 1")

    expect(request).to have_been_requested.once
  end
end

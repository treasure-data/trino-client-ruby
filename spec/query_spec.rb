require "spec_helper"

describe Trino::Client::Query do
  let(:faraday) do
    instance_double(Faraday::Connection)
  end

  let(:options) do
    {
      server: "localhost:8080",
      user: "test-user"
    }
  end

  describe ".start" do
    let(:statement_client) do
      instance_double(Trino::Client::StatementClient)
    end
    context "with a provided Faraday connection" do
      it "uses the provided connection without creating a new one" do
        expect(Trino::Client).not_to receive(:faraday_client)

        expect(Trino::Client::StatementClient)
          .to receive(:new)
          .with(faraday, "select 1", options)
          .and_return(statement_client)

        query = described_class.start("select 1", options, faraday)

        expect(query).to be_a(described_class)
      end
    end
    context "without a Faraday connection" do
      it "creates a connection when called with the original two arguments" do
        expect(Trino::Client)
          .to receive(:faraday_client)
          .with(options)
          .once
          .and_return(faraday)

        expect(Trino::Client::StatementClient)
          .to receive(:new)
          .with(faraday, "select 1", options)
          .and_return(statement_client)

        query = described_class.start("select 1", options)

        expect(query).to be_a(described_class)
      end
    end
  end

  describe ".resume" do
    let(:statement_client) do
      instance_double(Trino::Client::StatementClient)
    end

    let(:next_uri) do
      "http://localhost:8080/v1/statement/next"
    end
    context "with a provided Faraday connection" do
      it "uses the provided connection without creating a new one" do
        expect(Trino::Client).not_to receive(:faraday_client)

        expect(Trino::Client::StatementClient)
          .to receive(:new)
          .with(faraday, nil, options, next_uri)
          .and_return(statement_client)

        query = described_class.resume(next_uri, options, faraday)

        expect(query).to be_a(described_class)
      end
    end
    context "without a Faraday connection" do
      it "creates a connection when called with the original two arguments" do
        expect(Trino::Client)
          .to receive(:faraday_client)
          .with(options)
          .once
          .and_return(faraday)

        expect(Trino::Client::StatementClient)
          .to receive(:new)
          .with(faraday, nil, options, next_uri)
          .and_return(statement_client)

        query = described_class.resume(next_uri, options)

        expect(query).to be_a(described_class)
      end
    end
  end

  describe ".kill" do
    let(:request_headers) { {} }
    let(:request) { double("request", headers: request_headers) }
    let(:status) { 204 }
    let(:response) { instance_double(Faraday::Response, status: status) }
    before do
      expect(request)
        .to receive(:url)
        .with("/v1/query/query-id")

      expect(faraday)
        .to receive(:delete)
        .once
        .and_yield(request)
        .and_return(response)
    end

    context "with a provided Faraday connection" do
      before do
        expect(Trino::Client).not_to receive(:faraday_client)
      end

      it "deletes the query using the provided connection and query headers" do
        result = described_class.kill("query-id", options, faraday)

        expect(request_headers).to include("X-Trino-User" => "test-user")
        expect(result).to eq(true)
      end

      context "when the server returns a non-success status" do
        let(:status) { 500 }

        it "returns false" do
          result = described_class.kill("query-id", options, faraday)

          expect(result).to eq(false)
        end
      end
    end

    context "without a Faraday connection" do
      it "creates a connection and deletes the query with the original two arguments" do
        expect(Trino::Client)
          .to receive(:faraday_client)
          .with(options)
          .once
          .and_return(faraday)

        result = described_class.kill("query-id", options)

        expect(request_headers).to include("X-Trino-User" => "test-user")
        expect(result).to eq(true)
      end
    end
  end
end

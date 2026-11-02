require 'spec_helper'

describe Trino::Client::Client do
  let(:client) do
    Trino::Client.new(server: "localhost:8080")
  end

  describe "Faraday client reuse" do
    let(:options) do
      {
        server: "localhost:8080",
        user: "test-user"
      }
    end

    let(:faraday) do
      instance_double(Faraday::Connection)
    end

    before do
      allow(Trino::Client)
        .to receive(:faraday_client)
              .with(options)
              .and_return(faraday)
    end

    it "creates one Faraday client per Client instance" do
      expect(Trino::Client)
        .to receive(:faraday_client)
              .with(options)
              .once
              .and_return(faraday)

      described_class.new(options)
    end

    it "reuses the same Faraday client for multiple queries" do
      client = described_class.new(options)
      first_query = instance_double(Trino::Client::Query)
      second_query = instance_double(Trino::Client::Query)

      expect(Trino::Client::Query)
        .to receive(:start)
              .with("select 1", options, faraday)
              .and_return(first_query)

      expect(Trino::Client::Query)
        .to receive(:start)
              .with("select 2", options, faraday)
              .and_return(second_query)

      expect(client.query("select 1")).to eq(first_query)
      expect(client.query("select 2")).to eq(second_query)
    end

    it "reuses the same Faraday client when running a query" do
      client = described_class.new(options)
      query = instance_double(
        Trino::Client::Query,
        columns: [],
        close: nil
      )

      expect(Trino::Client::Query)
        .to receive(:start)
              .with("select 1", options, faraday)
              .and_return(query)

      expect(client.run("select 1")).to eq([[], []])
    end

    it "reuses the same Faraday client when resuming a query" do
      client = described_class.new(options)
      query = instance_double(Trino::Client::Query)
      next_uri = "http://localhost:8080/v1/statement/next"

      expect(Trino::Client::Query)
        .to receive(:resume)
              .with(next_uri, options, faraday)
              .and_return(query)

      expect(client.resume_query(next_uri)).to eq(query)
    end

    it "reuses the same Faraday client when killing a query" do
      client = described_class.new(options)

      expect(Trino::Client::Query)
        .to receive(:kill)
              .with("query-id", options, faraday)
              .and_return(true)

      expect(client.kill("query-id")).to eq(true)
    end

    it "creates a separate Faraday client for each Client instance" do
      first_faraday = instance_double(Faraday::Connection)
      second_faraday = instance_double(Faraday::Connection)

      expect(Trino::Client)
        .to receive(:faraday_client)
              .with(options)
              .twice
              .and_return(first_faraday, second_faraday)

      first_client = described_class.new(options)
      second_client = described_class.new(options)

      first_query = instance_double(Trino::Client::Query)
      second_query = instance_double(Trino::Client::Query)

      expect(Trino::Client::Query)
        .to receive(:start)
              .with("select 1", options, first_faraday)
              .and_return(first_query)

      expect(Trino::Client::Query)
        .to receive(:start)
              .with("select 2", options, second_faraday)
              .and_return(second_query)

      first_client.query("select 1")
      second_client.query("select 2")
    end
  end

  describe 'rehashes' do
    let(:columns) do
      [
        Models::Column.new(name: 'animal', type: 'string'),
        Models::Column.new(name: 'score', type: 'integer'),
        Models::Column.new(name: 'name', type: 'string'),
        Models::Column.new(name: 'foods', type: 'array(string string)'),
        Models::Column.new(name: 'traits', type: 'row(breed string, num_spots integer)')
      ]
    end

    it 'multiple rows' do
      rows = [
        ['dog', 1, 'Lassie', ['kibble', 'peanut butter'], ['spaniel', 2]],
        ['horse', 5, 'Mr. Ed', ['hay', 'sugar cubes'], ['some horse', 0]],
        ['t-rex', 37, 'Doug', ['rodents', 'small dinos'], ['dino', 0]]
      ]
      client.stub(:run).and_return([columns, rows])

      rehashed = client.run_with_names('fake query')

      expect(rehashed.length).to eq 3

      expect(rehashed[0]['animal']).to eq 'dog'
      expect(rehashed[0]['score']).to eq 1
      expect(rehashed[0]['name']).to eq 'Lassie'
      expect(rehashed[0]['foods']).to eq ['kibble', 'peanut butter']
      expect(rehashed[0]['traits']).to eq ['spaniel', 2]

      expect(rehashed[0].values[0]).to eq 'dog'
      expect(rehashed[0].values[1]).to eq 1
      expect(rehashed[0].values[2]).to eq 'Lassie'
      expect(rehashed[0].values[3]).to eq ['kibble', 'peanut butter']
      expect(rehashed[0].values[4]).to eq ['spaniel', 2]

      expect(rehashed[1]['animal']).to eq 'horse'
      expect(rehashed[1]['score']).to eq 5
      expect(rehashed[1]['name']).to eq 'Mr. Ed'
      expect(rehashed[1]['foods']).to eq ['hay', 'sugar cubes']
      expect(rehashed[1]['traits']).to eq ['some horse', 0]

      expect(rehashed[1].values[0]).to eq 'horse'
      expect(rehashed[1].values[1]).to eq 5
      expect(rehashed[1].values[2]).to eq 'Mr. Ed'
      expect(rehashed[1].values[3]).to eq ['hay', 'sugar cubes']
      expect(rehashed[1].values[4]).to eq ['some horse', 0]
    end

    it 'transforms rows into Ruby objects' do
      rows = [
        ['dog', 1, 'Lassie', ['kibble', 'peanut butter'], ['spaniel', 2]],
        ['horse', 5, 'Mr. Ed', ['hay', 'sugar cubes'], ['some horse', 0]],
        ['t-rex', 37, 'Doug', ['rodents', 'small dinos'], ['dino', 0]]
      ]
      client.stub(:run).and_return([columns, rows])

      query = Trino::Client::Query.new(nil)
      query.stub(:columns).and_return(columns)
      query.stub(:rows).and_return(rows)

      # For this test, we'll use scalar_parser to add 2 to every integer
      query.scalar_parser = ->(data, type) { (type == 'integer') ? data + 2 : data }

      columns, rows = client.run('fake query')
      transformed_rows = query.transform_rows

      expect(transformed_rows[0]).to eq({
        "animal" => "dog",
        "score" => 3,
        "name" => "Lassie",
        "foods" => ["kibble", "peanut butter"],
        "traits" => {
          "breed" => "spaniel",
          "num_spots" => 4,
        },
      })

      expect(transformed_rows[1]).to eq({
        "animal" => "horse",
        "score" => 7,
        "name" => "Mr. Ed",
        "foods" => ["hay", "sugar cubes"],
        "traits" => {
          "breed" => "some horse",
          "num_spots" => 2,
        },
      })

      # And to show that you can change the scalar_parser, now we only add 1 to each integer.
      query.scalar_parser = ->(data, type) { (type == 'integer') ? data + 1 : data }

      transformed_rows = query.transform_rows

      expect(transformed_rows[0]).to eq({
        "animal" => "dog",
        "score" => 2,
        "name" => "Lassie",
        "foods" => ["kibble", "peanut butter"],
        "traits" => {
          "breed" => "spaniel",
          "num_spots" => 3,
        },
      })

      expect(transformed_rows[1]).to eq({
        "animal" => "horse",
        "score" => 6,
        "name" => "Mr. Ed",
        "foods" => ["hay", "sugar cubes"],
        "traits" => {
          "breed" => "some horse",
          "num_spots" => 1,
        },
      })
    end

    it 'empty results' do
      rows = []
      client.stub(:run).and_return([columns, rows])

      rehashed = client.run_with_names('fake query')

      expect(rehashed.length).to eq 0
    end

    it 'handles too few result columns' do
      rows = [['wrong', 'count']]
      client.stub(:run).and_return([columns, rows])

      expect(client.run_with_names('fake query')).to eq [{
        "animal" => "wrong",
        "score" => "count",
        "name" => nil,
        "foods" => nil,
        "traits" => nil
      }]
    end

    it 'handles too many result columns' do
      rows = [['wrong', 'count', 'too', 'too', 'too', 'much', 'columns']]
      client.stub(:run).and_return([columns, rows])

      expect(client.run_with_names('fake query')).to eq [{
        "animal" => "wrong",
        "score" => "count",
        "name" => "too",
        "foods" => "too",
        "traits" => "too"
      }]
    end
  end
end

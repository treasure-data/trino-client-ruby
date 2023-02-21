require 'spec_helper'

describe Trino::Client::Client do
  let(:client) { Trino::Client.new({}) }

  describe 'rehashes' do
    let(:columns) do
      [
        Models::Column.new(name: 'animal', type: 'string'),
        Models::Column.new(name: 'score', type: 'integer'),
        Models::Column.new(name: 'name', type: 'string')
      ]
    end

    it 'multiple rows' do
      rows = [
        ['dog', 1, 'Lassie'],
        ['horse', 5, 'Mr. Ed'],
        ['t-rex', 37, 'Doug']
      ]
      client.stub(:run).and_return([columns, rows])

      rehashed = client.run_with_names('fake query')

      expect(rehashed.length).to eq 3

      expect(rehashed[0]['animal']).to eq 'dog'
      expect(rehashed[0]['score']).to eq 1
      expect(rehashed[0]['name']).to eq 'Lassie'

      expect(rehashed[0].values[0]).to eq 'dog'
      expect(rehashed[0].values[1]).to eq 1
      expect(rehashed[0].values[2]).to eq 'Lassie'

      expect(rehashed[1]['animal']).to eq 'horse'
      expect(rehashed[1]['score']).to eq 5
      expect(rehashed[1]['name']).to eq 'Mr. Ed'

      expect(rehashed[1].values[0]).to eq 'horse'
      expect(rehashed[1].values[1]).to eq 5
      expect(rehashed[1].values[2]).to eq 'Mr. Ed'
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
      }]
    end

    it 'handles too many result columns' do
      rows = [['wrong', 'count', 'too', 'much', 'columns']]
      client.stub(:run).and_return([columns, rows])

      expect(client.run_with_names('fake query')).to eq [{
        "animal" => "wrong",
        "score" => "count",
        "name" => 'too',
      }]
    end
  end
end

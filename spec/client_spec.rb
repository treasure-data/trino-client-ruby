require 'spec_helper'

describe Trino::Client::Client do
  let(:client) { Trino::Client.new({}) }

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

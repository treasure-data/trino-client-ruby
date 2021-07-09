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

      rehashed.length.should == 3

      rehashed[0]['animal'].should == 'dog'
      rehashed[0]['score'].should == 1
      rehashed[0]['name'].should == 'Lassie'

      rehashed[0].values[0].should == 'dog'
      rehashed[0].values[1].should == 1
      rehashed[0].values[2].should == 'Lassie'

      rehashed[1]['animal'].should == 'horse'
      rehashed[1]['score'].should == 5
      rehashed[1]['name'].should == 'Mr. Ed'

      rehashed[1].values[0].should == 'horse'
      rehashed[1].values[1].should == 5
      rehashed[1].values[2].should == 'Mr. Ed'
    end

    it 'empty results' do
      rows = []
      client.stub(:run).and_return([columns, rows])

      rehashed = client.run_with_names('fake query')

      rehashed.length.should == 0
    end

    it 'handles too few result columns' do
      rows = [['wrong', 'count']]
      client.stub(:run).and_return([columns, rows])

      client.run_with_names('fake query').should == [{
        "animal" => "wrong",
        "score" => "count",
        "name" => nil,
      }]
    end

    it 'handles too many result columns' do
      rows = [['wrong', 'count', 'too', 'much', 'columns']]
      client.stub(:run).and_return([columns, rows])

      client.run_with_names('fake query').should == [{
        "animal" => "wrong",
        "score" => "count",
        "name" => 'too',
      }]
    end
  end
end

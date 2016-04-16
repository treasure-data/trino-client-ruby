require 'spec_helper'

describe Presto::Client::Client do
  let(:client) { Presto::Client.new({}) }

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

      rehashed[0][0].should == 'dog'
      rehashed[0][1].should == 1
      rehashed[0][2].should == 'Lassie'
    end

    it 'empty results' do
      rows = []
      client.stub(:run).and_return([columns, rows])

      rehashed = client.run_with_names('fake query')

      rehashed.length.should == 0
    end

    it 'handles invalid results' do
      rows = [['wrong', 'count']]
      client.stub(:run).and_return([columns, rows])

      expect do
        client.run_with_names('fake query').should raise_error(ArgumentError)
      end.to raise_error(ArgumentError)
    end
  end
end

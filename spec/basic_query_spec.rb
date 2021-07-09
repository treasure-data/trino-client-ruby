require 'spec_helper'

describe Trino::Client::Client do
  before(:all) do
    WebMock.disable!
    @cluster = TinyPresto::Cluster.new()
    @container = @cluster.run
    @client = Trino::Client.new(server: 'localhost:8080', catalog: 'memory', user: 'test-user', schema: 'default')
    loop do
      begin
        @client.run('show schemas')
        break
      rescue StandardError => exception
        puts "Waiting for cluster ready... #{exception}"
        sleep(3)
      end
    end
    puts 'Cluster is ready'
  end

  after(:all) do
    @cluster.stop
    WebMock.enable!
  end

  it 'show schemas' do
    columns, rows = run_with_retry(@client, 'show schemas')
    expect(columns.length).to be(1)
    expect(rows.length).to be(2)
  end

  it 'ctas' do
    expected = [[1, 'a'], [2, 'b']]
    run_with_retry(@client, "create table ctas1 as select * from (values (1, 'a'), (2, 'b')) t(c1, c2)")
    columns, rows = run_with_retry(@client, 'select * from ctas1')
    expect(columns.map(&:name)).to match_array(%w[c1 c2])
    expect(rows).to eq(expected)
  end

  it 'next_uri' do
    @client.query('show schemas') do |q|
      expect(q.next_uri).to start_with('http://localhost:8080/v1/statement/')
    end
  end

  it 'advance' do
    @client.query('show schemas') do |q|
      expect(q.advance).to be(true)
    end
  end

  it 'current query result' do
    @client.query('show schemas') do |q|
      expect(q.current_results.info_uri).to start_with('http://localhost:8080/ui/query.html')
    end
  end

  it 'statement stats' do
    @client.query('show schemas') do |q|
      stats = q.current_results.stats
      # Immediate subsequent request should get queued result
      expect(stats.queued).to be(true)
      expect(stats.scheduled).to be(false)
    end
  end

  it 'partial cancel' do
    @client.query('show schemas') do |q|
      q.cancel
      expect { q.query_info }.to raise_error(Trino::Client::TrinoHttpError, /Error 410 Gone/)
    end
  end

  it 'row chunk' do
    expected_schemas = %w[default information_schema]
    @client.query('show schemas') do |q|
      q.each_row do |r|
        expect(expected_schemas).to include(r[0])
      end
    end
  end
end
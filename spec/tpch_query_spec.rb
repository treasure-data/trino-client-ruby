require 'spec_helper'

describe Trino::Client::Client do
  before(:all) do
    @spec_path = File.dirname(__FILE__)
    WebMock.disable!
    @cluster = TinyPresto::Cluster.new()
    @container = @cluster.run
    @client = Trino::Client.new(server: 'localhost:8080', catalog: 'tpch', user: 'test-user', schema: 'tiny')
    loop do
      begin
        # Make sure to all workers are available.
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

  it 'q01' do
    q = File.read("#{@spec_path}/tpch/q01.sql")
    columns, rows = run_with_retry(@client, q)
    expect(columns.length).to be(10)
    expect(rows.length).to be(4)
  end

  it 'q02' do
    q = File.read("#{@spec_path}/tpch/q02.sql")
    columns, rows = run_with_retry(@client, q)
    expect(columns.length).to be(8)
    expect(rows.length).to be(4)
  end
end
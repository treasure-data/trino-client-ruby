require 'spec_helper'

describe Presto::Client::Client do
  before(:all) do
    @spec_path = File.dirname(__FILE__)
    WebMock.disable!
    @cluster = TinyPresto::Cluster.new('ghcr.io/trinodb/presto', '316')
    @container = @cluster.run
    @client = Presto::Client.new(server: 'localhost:8080', catalog: 'tpch', user: 'test-user', schema: 'tiny', gzip: true, http_debug: true)
    loop do
      begin
        # Make sure to all workers are available.
        @client.run('select 1234')
        break
      rescue StandardError => exception
        puts "Waiting for cluster ready... #{exception}"
        sleep(5)
      end
    end
    puts 'Cluster is ready'
  end

  after(:all) do
    @cluster.stop
    WebMock.enable!
  end

  it 'tpch q01 with gzip option' do
    $stdout = StringIO.new
    begin
      q = File.read("#{@spec_path}/tpch/q01.sql")
      columns, rows = run_with_retry(@client, q)
      expect(columns.length).to be(10)
      expect(rows.length).to be(4)
      expect($stdout.string).to include ('content-encoding: "gzip"')
    ensure
      $stdout = STDOUT
    end
  end
end

module PrestoClient
  VERSION = "0.1.0"

  require 'faraday'
  require 'json'

  class ClientSession
    def initialize(options)
      @server = options[:server]
      @user = options[:user]
      @source = options[:source]
      @catalog = options[:catalog]
      @schema = options[:schema]
      @debug = !!options[:debug]
    end

    attr_reader :server
    attr_reader :user
    attr_reader :source
    attr_reader :catalog
    attr_reader :schema

    def debug?
      @debug
    end
  end

  #class StageStats
  #  attr_reader :stage_id
  #  attr_reader :state
  #  attr_reader :done
  #  attr_reader :nodes
  #  attr_reader :total_splits
  #  attr_reader :queued_splits
  #  attr_reader :running_splits
  #  attr_reader :completed_splits
  #  attr_reader :user_time_millis
  #  attr_reader :cpu_time_millis
  #  attr_reader :wall_time_millis
  #  attr_reader :processed_rows
  #  attr_reader :processed_bytes
  #  attr_reader :sub_stages
  #
  #  def initialize(options={})
  #    @stage_id = options[:stage_id]
  #    @state = options[:state]
  #    @done = options[:done]
  #    @nodes = options[:nodes]
  #    @total_splits = options[:total_splits]
  #    @queued_splits = options[:queued_splits]
  #    @running_splits = options[:running_splits]
  #    @completed_splits = options[:completed_splits]
  #    @user_time_millis = options[:user_time_millis]
  #    @cpu_time_millis = options[:cpu_time_millis]
  #    @wall_time_millis = options[:wall_time_millis]
  #    @processed_rows = options[:processed_rows]
  #    @processed_bytes = options[:processed_bytes]
  #    @sub_stages = options[:sub_stages]
  #  end
  #
  #  def self.decode_hash(hash)
  #    new(
  #      stage_id: hash["stageId"],
  #      state: hash["state"],
  #      done: hash["done"],
  #      nodes: hash["nodes"],
  #      total_splits: hash["totalSplits"],
  #      queued_splits: hash["queuedSplits"],
  #      running_splits: hash["runningSplits"],
  #      completed_splits: hash["completedSplits"],
  #      user_time_millis: hash["userTimeMillis"],
  #      cpu_time_millis: hash["cpuTimeMillis"],
  #      wall_time_millis: hash["wallTimeMillis"],
  #      processed_rows: hash["processedRows"],
  #      processed_bytes: hash["processedBytes"],
  #      sub_stages: hash["subStages"].map {|h| StageStats.decode_hash(h) },
  #    )
  #  end
  #end

  class StatementStats
    attr_reader :state
    attr_reader :scheduled
    attr_reader :nodes
    attr_reader :total_splits
    attr_reader :queued_splits
    attr_reader :running_splits
    attr_reader :completed_splits
    attr_reader :user_time_millis
    attr_reader :cpu_time_millis
    attr_reader :wall_time_millis
    attr_reader :processed_rows
    attr_reader :processed_bytes
    #attr_reader :root_stage

    def initialize(options={})
      @state = state
      @scheduled = scheduled
      @nodes = nodes
      @total_splits = total_splits
      @queued_splits = queued_splits
      @running_splits = running_splits
      @completed_splits = completed_splits
      @user_time_millis = user_time_millis
      @cpu_time_millis = cpu_time_millis
      @wall_time_millis = wall_time_millis
      @processed_rows = processed_rows
      @processed_bytes = processed_bytes
      #@root_stage = root_stage
    end

    def self.decode_hash(hash)
      new(
        state: hash["state"],
        scheduled: hash["scheduled"],
        nodes: hash["nodes"],
        total_splits: hash["totalSplits"],
        queued_splits: hash["queuedSplits"],
        running_splits: hash["runningSplits"],
        completed_splits: hash["completedSplits"],
        user_time_millis: hash["userTimeMillis"],
        cpu_time_millis: hash["cpuTimeMillis"],
        wall_time_millis: hash["wallTimeMillis"],
        processed_rows: hash["processedRows"],
        processed_bytes: hash["processedBytes"],
        #root_stage: StageStats.decode_hash(hash["rootStage"]),
      )
    end
  end

  class Column
    attr_reader :name
    attr_reader :type

    def initialize(options={})
      @name = options[:name]
      @type = options[:type]
    end

    def self.decode_hash(hash)
      new(
        name: hash["name"],
        type: hash["type"],
      )
    end
  end

  class QueryResults
    attr_reader :id
    attr_reader :info_uri
    attr_reader :partial_cache_uri
    attr_reader :next_uri
    attr_reader :columns
    attr_reader :data
    attr_reader :stats
    attr_reader :error

    def initialize(options={})
      @id = options[:id]
      @info_uri = options[:info_uri]
      @partial_cache_uri = options[:partial_cache_uri]
      @next_uri = options[:next_uri]
      @columns = options[:columns]
      @data = options[:data]
      @stats = options[:stats]
      @error = options[:error]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"],
        info_uri: hash["infoUri"],
        partial_cache_uri: hash["partialCancelUri"],
        next_uri: hash["nextUri"],
        columns: hash["columns"] ? hash["columns"].map {|h| Column.decode_hash(h) } : nil,
        data: hash["data"]
        stats: StatementStats.decode_hash(hash["stats"]),
        error: hash["error"],  # TODO
      )
    end
  end

  module PrestoHeaders
    PRESTO_USER = "X-Presto-User"
    PRESTO_SOURCE = "X-Presto-Source"
    PRESTO_CATALOG = "X-Presto-Catalog"
    PRESTO_SCHEMA = "X-Presto-Schema"

    PRESTO_CURRENT_STATE = "X-Presto-Current-State"
    PRESTO_MAX_WAIT = "X-Presto-Max-Wait"
    PRESTO_MAX_SIZE = "X-Presto-Max-Size"
    PRESTO_PAGE_SEQUENCE_ID = "X-Presto-Page-Sequence-Id"
  end

  class StatementClient
    HEADERS = {
      "User-Agent" => "presto-ruby/#{VERSION}"
    }

    def initialize(faraday, session, query)
      @faraday = faraday
      @faraday.headers.merge!(HEADERS)

      @session = session
      @query = query
      @closed = false
      @exception = nil
      post_query_request!
    end

    def post_query_request!
      response = @faraday.post do |req|
        req.url "/v1/statement"

        if v = @session.user
          req.headers[PrestoHeaders::PRESTO_USER] = v
        end
        if v = @session.source
          req.headers[PrestoHeaders::PRESTO_SOURCE] = v
        end
        if catalog = @session.catalog
          req.headers[PrestoHeaders::PRESTO_CATALOG] = catalog
        end
        if v = @session.schema
          req.headers[PrestoHeaders::PRESTO_SCHEMA] = v
        end

        req.body = @query
      end

      # TODO error handling
      if response.status != 200
        raise "Failed to start query: #{response.body}"  # TODO error class
      end

      body = response.body
      hash = JSON.parse(body)
      @results = QueryResults.decode_hash(hash)
    end

    private :post_query_request!

    attr_reader :query

    def debug?
      @session.debug?
    end

    def closed?
      @closed
    end

    attr_reader :exception

    def exception?
      @exception
    end

    def query_failed?
      @results.error != nil
    end

    def query_succeeded?
      @results.error == nil && !@exception && !@closed
    end

    def current_results
      @results
    end

    def has_next?
      !!@results.next_uri
    end

    def advance
      if closed? || !has_next?
        return false
      end
      uri = @results.next_uri

      start = Time.now
      attempts = 0

      begin
        begin
          response = @faraday.get do |req|
            req.url uri
          end
        rescue => e
          @exception = e
          raise @exception
        end

        if response.status == 200 && !response.body.to_s.empty?
          @results = QueryResults.decode_hash(JSON.parse(response.body))
          return true
        end

        if response.status != 503  # retry on 503 Service Unavailable
          # deterministic error
          @exception = StandardError.new("Error fetching next at #{uri} returned #{response.status}: #{response.body}")  # TODO error class
          raise @exception
        end

        attempts += 1
        sleep attempts * 0.1
      end while (Time.now - start) < 2*60*60 && !@closed

      @exception = StandardError.new("Error fetching next")  # TODO error class
      raise @exception
    end

    def close
      return if @closed

      # cancel running statement
      if uri = @results.next_uri
        # TODO error handling
        # TODO make async reqeust and ignore response
        @faraday.delete do |req|
          req.url uri
        end
      end

      @closed = true
      nil
    end
  end

  class Query
    def self.start(session, query)
      faraday = Faraday.new(url: "http://#{session.server}") do |faraday|
        faraday.request :url_encoded
        faraday.response :logger
        faraday.adapter Faraday.default_adapter
      end

      new StatementClient.new(faraday, session, query)
    end

    def initialize(client)
      @client = client
    end

    def wait_for_data
      while @client.has_next? && @client.current_results.data == nil
        @client.advance
      end
    end

    private :wait_for_data

    def columns
      wait_for_data

      raise_error unless @client.query_succeeded?

      return @client.current_results.columns
    end

    def each_row(&block)
      wait_for_data

      raise_error unless @client.query_succeeded?

      if self.columns == nil
        raise "Query #{@client.current_results.id} has no columns"
      end

      begin
        if data = @client.current_results.data
          data.each(&block)
        end
        @client.advance
      end while @client.has_next?
    end

    def raise_error
      if @client.closed?
        raise "Query aborted by user"
      elsif @client.exception?
        raise "Query is gone: #{@client.exception}"
      elsif @client.query_failed?
        results = @client.current_results
        # TODO error location
        raise "Query #{results.id} failed: #{results.error}"
      end
    end

    private :raise_error
  end

  class Client
    def initialize(options)
      @session = ClientSession.new(options)
    end

    def query(query)
      Query.start(@session, query)
    end
  end
end

require 'pp'

client = PrestoClient::Client.new(
  server: "localhost:8880",
  user: "frsyuki",
  catalog: "native",
  schema: "default",
  debug: true
)

q = client.query("select * from sys.query")
p q.columns
q.each_row {|row|
  p row
}


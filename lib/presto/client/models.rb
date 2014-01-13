#
# Presto client for Ruby
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
module Presto::Client

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

  class StageStats
    attr_reader :stage_id
    attr_reader :state
    attr_reader :done
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
    attr_reader :sub_stages

    def initialize(options={})
      @stage_id = options[:stage_id]
      @state = options[:state]
      @done = options[:done]
      @nodes = options[:nodes]
      @total_splits = options[:total_splits]
      @queued_splits = options[:queued_splits]
      @running_splits = options[:running_splits]
      @completed_splits = options[:completed_splits]
      @user_time_millis = options[:user_time_millis]
      @cpu_time_millis = options[:cpu_time_millis]
      @wall_time_millis = options[:wall_time_millis]
      @processed_rows = options[:processed_rows]
      @processed_bytes = options[:processed_bytes]
      @sub_stages = options[:sub_stages]
    end

    def self.decode_hash(hash)
      new(
        stage_id: hash["stageId"],
        state: hash["state"],
        done: hash["done"],
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
        sub_stages: hash["subStages"] && hash["subStages"].map {|h| StageStats.decode_hash(h) },
      )
    end
  end

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
    attr_reader :root_stage

    def initialize(options={})
      @state = options[:state]
      @scheduled = options[:scheduled]
      @nodes = options[:nodes]
      @total_splits = options[:total_splits]
      @queued_splits = options[:queued_splits]
      @running_splits = options[:running_splits]
      @completed_splits = options[:completed_splits]
      @user_time_millis = options[:user_time_millis]
      @cpu_time_millis = options[:cpu_time_millis]
      @wall_time_millis = options[:wall_time_millis]
      @processed_rows = options[:processed_rows]
      @processed_bytes = options[:processed_bytes]
      @root_stage = options[:root_stage]
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
        root_stage: hash["rootStage"] && StageStats.decode_hash(hash["rootStage"]),
      )
    end
  end

  class ErrorLocation
    attr_reader :line_number
    attr_reader :column_number

    def initialize(options={})
      @line_number = options[:line_number]
      @column_number = options[:column_number]
    end

    def self.decode_hash(hash)
      new(
        line_number: hash["lineNumber"],
        column_number: hash["columnNumber"],
      )
    end
  end

  class FailureInfo
    attr_reader :type
    attr_reader :message
    attr_reader :cause
    attr_reader :suppressed
    attr_reader :stack
    attr_reader :error_location

    def initialize(options={})
      @type = options[:type]
      @message = options[:message]
      @cause = options[:cause]
      @suppressed = options[:suppressed]
      @stack = options[:stack]
      @error_location = options[:error_location]
    end

    def self.decode_hash(hash)
      new(
        type: hash["type"],
        message: hash["message"],
        cause: hash["cause"],
        suppressed: hash["suppressed"] && hash["suppressed"].map {|h| FailureInfo.decode_hash(h) },
        stack: hash["stack"],
        error_location: hash["errorLocation"] && ErrorLocation.decode_hash(hash["errorLocation"]),
      )
    end
  end

  class QueryError
    attr_reader :message
    attr_reader :sql_state
    attr_reader :error_code
    attr_reader :error_location
    attr_reader :failure_info

    def initialize(options={})
      @message = options[:message]
      @sql_state = options[:sql_state]
      @error_code = options[:error_code]
      @error_location = options[:error_location]
      @failure_info = options[:failure_info]
    end

    def self.decode_hash(hash)
      new(
        message: hash["message"],
        sql_state: hash["sqlState"],
        error_code: hash["errorCode"],
        error_location: hash["errorLocation"] && ErrorLocation.decode_hash(hash["errorLocation"]),
        failure_info: hash["failureInfo"] && FailureInfo.decode_hash(hash["failureInfo"]),
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
        columns: hash["columns"] && hash["columns"].map {|h| Column.decode_hash(h) },
        data: hash["data"],
        stats: hash["stats"] && StatementStats.decode_hash(hash["stats"]),
        error: hash["error"] && QueryError.decode_hash(hash["error"]),
      )
    end
  end

end

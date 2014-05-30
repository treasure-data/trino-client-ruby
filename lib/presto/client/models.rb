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

  ####
  ## lib/presto/client/models.rb is automatically generated using "rake modelgen" command.
  ## You should not edit this file directly. To modify the class definitions, edit
  ## modelgen/models.rb file and run "rake modelgen".
  ##

  class QueryId < String
  end

  class StageId < String
  end

  class TaskId < String
  end

  class PlanNodeId < String
  end

  class PlanFragmentId < String
  end

  class ConnectorSession < Hash
    def initialize(hash)
      super()
      merge!(hash)
    end
  end

  module PlanNode
    def self.decode_hash(hash)
      model_class = case hash["type"]
        when "output"             then OutputNode
        when "project"            then ProjectNode
        when "tablescan"          then TableScanNode
        when "values"             then ValuesNode
        when "aggregation"        then AggregationNode
        when "markDistinct"       then MarkDistinctNode
        when "materializeSample"  then MaterializeSampleNode
        when "filter"             then FilterNode
        when "window"             then WindowNode
        when "limit"              then LimitNode
        when "distinctlimit"      then DistinctLimitNode
        when "topn"               then TopNNode
        when "sample"             then SampleNode
        when "sort"               then SortNode
        when "exchange"           then ExchangeNode
        when "sink"               then SinkNode
        when "join"               then JoinNode
        when "semijoin"           then SemiJoinNode
        when "indexjoin"          then IndexJoinNode
        when "indexsource"        then IndexSourceNode
        when "tablewriter"        then TableWriterNode
        when "tablecommit"        then TableCommitNode
        end
      model_class.decode_hash(hash)
    end
  end

  # io.airlift.stats.Distribution.DistributionSnapshot
  class DistributionSnapshot
    attr_reader :max_error
    attr_reader :count
    attr_reader :total
    attr_reader :p01
    attr_reader :p05
    attr_reader :p10
    attr_reader :p25
    attr_reader :p50
    attr_reader :p75
    attr_reader :p90
    attr_reader :p95
    attr_reader :p99
    attr_reader :min
    attr_reader :max

    def initialize(options={})
      @max_error = options[:maxError]
      @count = options[:count]
      @total = options[:total]
      @p01 = options[:p01]
      @p05 = options[:p05]
      @p10 = options[:p10]
      @p25 = options[:p25]
      @p50 = options[:p50]
      @p75 = options[:p75]
      @p90 = options[:p90]
      @p95 = options[:p95]
      @p99 = options[:p99]
      @min = options[:min]
      @max = options[:max]
    end

    def self.decode_hash(hash)
      new(
        max_error: hash["maxError"],
        count: hash["count"],
        total: hash["total"],
        p01: hash["p01"],
        p05: hash["p05"],
        p10: hash["p10"],
        p25: hash["p25"],
        p50: hash["p50"],
        p75: hash["p75"],
        p90: hash["p90"],
        p95: hash["p95"],
        p99: hash["p99"],
        min: hash["min"],
        max: hash["max"],
      )
    end
  end


  ##
  # Those model classes are automatically generated
  #

  class AggregationNode
    attr_reader :id
    attr_reader :source
    attr_reader :group_by
    attr_reader :aggregations
    attr_reader :functions
    attr_reader :masks
    attr_reader :step
    attr_reader :sample_weight
    attr_reader :confidence

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @group_by = options[:group_by]
      @aggregations = options[:aggregations]
      @functions = options[:functions]
      @masks = options[:masks]
      @step = options[:step]
      @sample_weight = options[:sample_weight]
      @confidence = options[:confidence]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        group_by: hash["groupBy"],
        aggregations: hash["aggregations"],
        functions: hash["functions"] && Hash[hash["functions"].to_a.map! {|k,v| [k, Signature.decode_hash(v)] }],
        masks: hash["masks"],
        step: hash["step"] && hash["step"].downcase.to_sym,
        sample_weight: hash["sampleWeight"],
        confidence: hash["confidence"],
      )
    end
  end

  class BufferInfo
    attr_reader :buffer_id
    attr_reader :finished
    attr_reader :buffered_pages
    attr_reader :pages_sent

    def initialize(options={})
      @buffer_id = options[:buffer_id]
      @finished = options[:finished]
      @buffered_pages = options[:buffered_pages]
      @pages_sent = options[:pages_sent]
    end

    def self.decode_hash(hash)
      new(
        buffer_id: hash["bufferId"],
        finished: hash["finished"],
        buffered_pages: hash["bufferedPages"],
        pages_sent: hash["pagesSent"],
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

  class ColumnHandle
    attr_reader :connector_id
    attr_reader :connector_handle

    def initialize(options={})
      @connector_id = options[:connector_id]
      @connector_handle = options[:connector_handle]
    end

    def self.decode_hash(hash)
      new(
        connector_id: hash["connectorId"],
        connector_handle: hash["connectorHandle"],
      )
    end
  end

  class DistinctLimitNode
    attr_reader :id
    attr_reader :source
    attr_reader :limit

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @limit = options[:limit]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        limit: hash["limit"],
      )
    end
  end

  class DriverStats
    attr_reader :create_time
    attr_reader :start_time
    attr_reader :end_time
    attr_reader :queued_time
    attr_reader :elapsed_time
    attr_reader :memory_reservation
    attr_reader :total_scheduled_time
    attr_reader :total_cpu_time
    attr_reader :total_user_time
    attr_reader :total_blocked_time
    attr_reader :raw_input_data_size
    attr_reader :raw_input_positions
    attr_reader :raw_input_read_time
    attr_reader :processed_input_data_size
    attr_reader :processed_input_positions
    attr_reader :output_data_size
    attr_reader :output_positions
    attr_reader :operator_stats

    def initialize(options={})
      @create_time = options[:create_time]
      @start_time = options[:start_time]
      @end_time = options[:end_time]
      @queued_time = options[:queued_time]
      @elapsed_time = options[:elapsed_time]
      @memory_reservation = options[:memory_reservation]
      @total_scheduled_time = options[:total_scheduled_time]
      @total_cpu_time = options[:total_cpu_time]
      @total_user_time = options[:total_user_time]
      @total_blocked_time = options[:total_blocked_time]
      @raw_input_data_size = options[:raw_input_data_size]
      @raw_input_positions = options[:raw_input_positions]
      @raw_input_read_time = options[:raw_input_read_time]
      @processed_input_data_size = options[:processed_input_data_size]
      @processed_input_positions = options[:processed_input_positions]
      @output_data_size = options[:output_data_size]
      @output_positions = options[:output_positions]
      @operator_stats = options[:operator_stats]
    end

    def self.decode_hash(hash)
      new(
        create_time: hash["createTime"],
        start_time: hash["startTime"],
        end_time: hash["endTime"],
        queued_time: hash["queuedTime"],
        elapsed_time: hash["elapsedTime"],
        memory_reservation: hash["memoryReservation"],
        total_scheduled_time: hash["totalScheduledTime"],
        total_cpu_time: hash["totalCpuTime"],
        total_user_time: hash["totalUserTime"],
        total_blocked_time: hash["totalBlockedTime"],
        raw_input_data_size: hash["rawInputDataSize"],
        raw_input_positions: hash["rawInputPositions"],
        raw_input_read_time: hash["rawInputReadTime"],
        processed_input_data_size: hash["processedInputDataSize"],
        processed_input_positions: hash["processedInputPositions"],
        output_data_size: hash["outputDataSize"],
        output_positions: hash["outputPositions"],
        operator_stats: hash["operatorStats"] && hash["operatorStats"].map {|h| OperatorStats.decode_hash(h) },
      )
    end
  end

  class ErrorCode
    attr_reader :code
    attr_reader :name

    def initialize(options={})
      @code = options[:code]
      @name = options[:name]
    end

    def self.decode_hash(hash)
      new(
        code: hash["code"],
        name: hash["name"],
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

  class ExchangeNode
    attr_reader :id
    attr_reader :source_fragment_ids
    attr_reader :outputs

    def initialize(options={})
      @id = options[:id]
      @source_fragment_ids = options[:source_fragment_ids]
      @outputs = options[:outputs]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source_fragment_ids: hash["sourceFragmentIds"] && hash["sourceFragmentIds"].map {|h| PlanFragmentId.new(h) },
        outputs: hash["outputs"],
      )
    end
  end

  class ExecutionFailureInfo
    attr_reader :type
    attr_reader :message
    attr_reader :cause
    attr_reader :suppressed
    attr_reader :stack
    attr_reader :error_location
    attr_reader :error_code

    def initialize(options={})
      @type = options[:type]
      @message = options[:message]
      @cause = options[:cause]
      @suppressed = options[:suppressed]
      @stack = options[:stack]
      @error_location = options[:error_location]
      @error_code = options[:error_code]
    end

    def self.decode_hash(hash)
      new(
        type: hash["type"],
        message: hash["message"],
        cause: hash["cause"] && ExecutionFailureInfo.decode_hash(hash["cause"]),
        suppressed: hash["suppressed"] && hash["suppressed"].map {|h| ExecutionFailureInfo.decode_hash(h) },
        stack: hash["stack"],
        error_location: hash["errorLocation"] && ErrorLocation.decode_hash(hash["errorLocation"]),
        error_code: hash["errorCode"] && ErrorCode.decode_hash(hash["errorCode"]),
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
        cause: hash["cause"] && FailureInfo.decode_hash(hash["cause"]),
        suppressed: hash["suppressed"] && hash["suppressed"].map {|h| FailureInfo.decode_hash(h) },
        stack: hash["stack"],
        error_location: hash["errorLocation"] && ErrorLocation.decode_hash(hash["errorLocation"]),
      )
    end
  end

  class FilterNode
    attr_reader :id
    attr_reader :source
    attr_reader :predicate

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @predicate = options[:predicate]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        predicate: hash["predicate"],
      )
    end
  end

  class IndexHandle
    attr_reader :connector_id
    attr_reader :connector_handle

    def initialize(options={})
      @connector_id = options[:connector_id]
      @connector_handle = options[:connector_handle]
    end

    def self.decode_hash(hash)
      new(
        connector_id: hash["connectorId"],
        connector_handle: hash["connectorHandle"],
      )
    end
  end

  class IndexJoinNode
    attr_reader :id
    attr_reader :type
    attr_reader :probe_source
    attr_reader :index_source

    def initialize(options={})
      @id = options[:id]
      @type = options[:type]
      @probe_source = options[:probe_source]
      @index_source = options[:index_source]
      @criteria = options[:criteria]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        type: hash["type"],
        probe_source: hash["probeSource"] && PlanNode.decode_hash(hash["probeSource"]),
        index_source: hash["indexSource"] && PlanNode.decode_hash(hash["indexSource"]),
      )
    end
  end

  class IndexSourceNode
    attr_reader :id
    attr_reader :index_handle
    attr_reader :table_handle
    attr_reader :lookup_symbols
    attr_reader :output_symbols
    attr_reader :assignments

    def initialize(options={})
      @id = options[:id]
      @index_handle = options[:index_handle]
      @table_handle = options[:table_handle]
      @lookup_symbols = options[:lookup_symbols]
      @output_symbols = options[:output_symbols]
      @assignments = options[:assignments]
      @effective_tuple_domain = options[:effective_tuple_domain]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        index_handle: hash["indexHandle"] && IndexHandle.decode_hash(hash["indexHandle"]),
        table_handle: hash["tableHandle"] && TableHandle.decode_hash(hash["tableHandle"]),
        lookup_symbols: hash["lookupSymbols"],
        output_symbols: hash["outputSymbols"],
        assignments: hash["assignments"] && Hash[hash["assignments"].to_a.map! {|k,v| [k, ColumnHandle.decode_hash(v)] }],
      )
    end
  end

  class Input
    attr_reader :connector_id
    attr_reader :schema
    attr_reader :table
    attr_reader :columns

    def initialize(options={})
      @connector_id = options[:connector_id]
      @schema = options[:schema]
      @table = options[:table]
      @columns = options[:columns]
    end

    def self.decode_hash(hash)
      new(
        connector_id: hash["connectorId"],
        schema: hash["schema"],
        table: hash["table"],
        columns: hash["columns"] && hash["columns"].map {|h| Column.decode_hash(h) },
      )
    end
  end

  class JoinNode
    attr_reader :id
    attr_reader :type
    attr_reader :left
    attr_reader :right

    def initialize(options={})
      @id = options[:id]
      @type = options[:type]
      @left = options[:left]
      @right = options[:right]
      @criteria = options[:criteria]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        type: hash["type"],
        left: hash["left"] && PlanNode.decode_hash(hash["left"]),
        right: hash["right"] && PlanNode.decode_hash(hash["right"]),
      )
    end
  end

  class LimitNode
    attr_reader :id
    attr_reader :source
    attr_reader :count
    attr_reader :sample_weight

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @count = options[:count]
      @sample_weight = options[:sample_weight]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        count: hash["count"],
        sample_weight: hash["sampleWeight"],
      )
    end
  end

  class MarkDistinctNode
    attr_reader :id
    attr_reader :source
    attr_reader :marker_symbol
    attr_reader :distinct_symbols
    attr_reader :sample_weight_symbol

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @marker_symbol = options[:marker_symbol]
      @distinct_symbols = options[:distinct_symbols]
      @sample_weight_symbol = options[:sample_weight_symbol]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        marker_symbol: hash["markerSymbol"],
        distinct_symbols: hash["distinctSymbols"],
        sample_weight_symbol: hash["sampleWeightSymbol"],
      )
    end
  end

  class MaterializeSampleNode
    attr_reader :id
    attr_reader :source
    attr_reader :sample_weight_symbol

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @sample_weight_symbol = options[:sample_weight_symbol]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        sample_weight_symbol: hash["sampleWeightSymbol"],
      )
    end
  end

  class OperatorStats
    attr_reader :operator_id
    attr_reader :operator_type
    attr_reader :add_input_calls
    attr_reader :add_input_wall
    attr_reader :add_input_cpu
    attr_reader :add_input_user
    attr_reader :input_data_size
    attr_reader :input_positions
    attr_reader :get_output_calls
    attr_reader :get_output_wall
    attr_reader :get_output_cpu
    attr_reader :get_output_user
    attr_reader :output_data_size
    attr_reader :output_positions
    attr_reader :blocked_wall
    attr_reader :finish_calls
    attr_reader :finish_wall
    attr_reader :finish_cpu
    attr_reader :finish_user
    attr_reader :memory_reservation
    attr_reader :info

    def initialize(options={})
      @operator_id = options[:operator_id]
      @operator_type = options[:operator_type]
      @add_input_calls = options[:add_input_calls]
      @add_input_wall = options[:add_input_wall]
      @add_input_cpu = options[:add_input_cpu]
      @add_input_user = options[:add_input_user]
      @input_data_size = options[:input_data_size]
      @input_positions = options[:input_positions]
      @get_output_calls = options[:get_output_calls]
      @get_output_wall = options[:get_output_wall]
      @get_output_cpu = options[:get_output_cpu]
      @get_output_user = options[:get_output_user]
      @output_data_size = options[:output_data_size]
      @output_positions = options[:output_positions]
      @blocked_wall = options[:blocked_wall]
      @finish_calls = options[:finish_calls]
      @finish_wall = options[:finish_wall]
      @finish_cpu = options[:finish_cpu]
      @finish_user = options[:finish_user]
      @memory_reservation = options[:memory_reservation]
      @info = options[:info]
    end

    def self.decode_hash(hash)
      new(
        operator_id: hash["operatorId"],
        operator_type: hash["operatorType"],
        add_input_calls: hash["addInputCalls"],
        add_input_wall: hash["addInputWall"],
        add_input_cpu: hash["addInputCpu"],
        add_input_user: hash["addInputUser"],
        input_data_size: hash["inputDataSize"],
        input_positions: hash["inputPositions"],
        get_output_calls: hash["getOutputCalls"],
        get_output_wall: hash["getOutputWall"],
        get_output_cpu: hash["getOutputCpu"],
        get_output_user: hash["getOutputUser"],
        output_data_size: hash["outputDataSize"],
        output_positions: hash["outputPositions"],
        blocked_wall: hash["blockedWall"],
        finish_calls: hash["finishCalls"],
        finish_wall: hash["finishWall"],
        finish_cpu: hash["finishCpu"],
        finish_user: hash["finishUser"],
        memory_reservation: hash["memoryReservation"],
        info: hash["info"],
      )
    end
  end

  class OutputNode
    attr_reader :id
    attr_reader :source
    attr_reader :columns
    attr_reader :outputs

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @columns = options[:columns]
      @outputs = options[:outputs]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        columns: hash["columns"],
        outputs: hash["outputs"],
      )
    end
  end

  class OutputTableHandle
    attr_reader :connector_id
    attr_reader :connector_handle

    def initialize(options={})
      @connector_id = options[:connector_id]
      @connector_handle = options[:connector_handle]
    end

    def self.decode_hash(hash)
      new(
        connector_id: hash["connectorId"],
        connector_handle: hash["connectorHandle"],
      )
    end
  end

  class PipelineStats
    attr_reader :input_pipeline
    attr_reader :output_pipeline
    attr_reader :total_drivers
    attr_reader :queued_drivers
    attr_reader :running_drivers
    attr_reader :completed_drivers
    attr_reader :memory_reservation
    attr_reader :queued_time
    attr_reader :elapsed_time
    attr_reader :total_scheduled_time
    attr_reader :total_cpu_time
    attr_reader :total_user_time
    attr_reader :total_blocked_time
    attr_reader :raw_input_data_size
    attr_reader :raw_input_positions
    attr_reader :processed_input_data_size
    attr_reader :processed_input_positions
    attr_reader :output_data_size
    attr_reader :output_positions
    attr_reader :operator_summaries
    attr_reader :drivers

    def initialize(options={})
      @input_pipeline = options[:input_pipeline]
      @output_pipeline = options[:output_pipeline]
      @total_drivers = options[:total_drivers]
      @queued_drivers = options[:queued_drivers]
      @running_drivers = options[:running_drivers]
      @completed_drivers = options[:completed_drivers]
      @memory_reservation = options[:memory_reservation]
      @queued_time = options[:queued_time]
      @elapsed_time = options[:elapsed_time]
      @total_scheduled_time = options[:total_scheduled_time]
      @total_cpu_time = options[:total_cpu_time]
      @total_user_time = options[:total_user_time]
      @total_blocked_time = options[:total_blocked_time]
      @raw_input_data_size = options[:raw_input_data_size]
      @raw_input_positions = options[:raw_input_positions]
      @processed_input_data_size = options[:processed_input_data_size]
      @processed_input_positions = options[:processed_input_positions]
      @output_data_size = options[:output_data_size]
      @output_positions = options[:output_positions]
      @operator_summaries = options[:operator_summaries]
      @drivers = options[:drivers]
    end

    def self.decode_hash(hash)
      new(
        input_pipeline: hash["inputPipeline"],
        output_pipeline: hash["outputPipeline"],
        total_drivers: hash["totalDrivers"],
        queued_drivers: hash["queuedDrivers"],
        running_drivers: hash["runningDrivers"],
        completed_drivers: hash["completedDrivers"],
        memory_reservation: hash["memoryReservation"],
        queued_time: hash["queuedTime"] && DistributionSnapshot.decode_hash(hash["queuedTime"]),
        elapsed_time: hash["elapsedTime"] && DistributionSnapshot.decode_hash(hash["elapsedTime"]),
        total_scheduled_time: hash["totalScheduledTime"],
        total_cpu_time: hash["totalCpuTime"],
        total_user_time: hash["totalUserTime"],
        total_blocked_time: hash["totalBlockedTime"],
        raw_input_data_size: hash["rawInputDataSize"],
        raw_input_positions: hash["rawInputPositions"],
        processed_input_data_size: hash["processedInputDataSize"],
        processed_input_positions: hash["processedInputPositions"],
        output_data_size: hash["outputDataSize"],
        output_positions: hash["outputPositions"],
        operator_summaries: hash["operatorSummaries"] && hash["operatorSummaries"].map {|h| OperatorStats.decode_hash(h) },
        drivers: hash["drivers"] && hash["drivers"].map {|h| DriverStats.decode_hash(h) },
      )
    end
  end

  class PlanFragment
    attr_reader :id
    attr_reader :root
    attr_reader :symbols
    attr_reader :distribution
    attr_reader :partitioned_source
    attr_reader :output_partitioning
    attr_reader :partition_by

    def initialize(options={})
      @id = options[:id]
      @root = options[:root]
      @symbols = options[:symbols]
      @distribution = options[:distribution]
      @partitioned_source = options[:partitioned_source]
      @output_partitioning = options[:output_partitioning]
      @partition_by = options[:partition_by]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanFragmentId.new(hash["id"]),
        root: hash["root"] && PlanNode.decode_hash(hash["root"]),
        symbols: hash["symbols"],
        distribution: hash["distribution"] && hash["distribution"].downcase.to_sym,
        partitioned_source: hash["partitionedSource"] && PlanNodeId.new(hash["partitionedSource"]),
        output_partitioning: hash["outputPartitioning"] && hash["outputPartitioning"].downcase.to_sym,
        partition_by: hash["partitionBy"],
      )
    end
  end

  class ProjectNode
    attr_reader :id
    attr_reader :source
    attr_reader :assignments

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @assignments = options[:assignments]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        assignments: hash["assignments"],
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

  class QueryInfo
    attr_reader :query_id
    attr_reader :session
    attr_reader :state
    attr_reader :self
    attr_reader :field_names
    attr_reader :query
    attr_reader :query_stats
    attr_reader :output_stage
    attr_reader :failure_info
    attr_reader :error_code
    attr_reader :inputs

    def initialize(options={})
      @query_id = options[:query_id]
      @session = options[:session]
      @state = options[:state]
      @self = options[:self]
      @field_names = options[:field_names]
      @query = options[:query]
      @query_stats = options[:query_stats]
      @output_stage = options[:output_stage]
      @failure_info = options[:failure_info]
      @error_code = options[:error_code]
      @inputs = options[:inputs]
    end

    def self.decode_hash(hash)
      new(
        query_id: hash["queryId"] && QueryId.new(hash["queryId"]),
        session: hash["session"] && ConnectorSession.new(hash["session"]),
        state: hash["state"] && hash["state"].downcase.to_sym,
        self: hash["self"],
        field_names: hash["fieldNames"],
        query: hash["query"],
        query_stats: hash["queryStats"] && QueryStats.decode_hash(hash["queryStats"]),
        output_stage: hash["outputStage"] && StageInfo.decode_hash(hash["outputStage"]),
        failure_info: hash["failureInfo"] && FailureInfo.decode_hash(hash["failureInfo"]),
        error_code: hash["errorCode"] && ErrorCode.decode_hash(hash["errorCode"]),
        inputs: hash["inputs"] && hash["inputs"].map {|h| Input.decode_hash(h) },
      )
    end
  end

  class QueryResults
    attr_reader :id
    attr_reader :info_uri
    attr_reader :partial_cancel_uri
    attr_reader :next_uri
    attr_reader :columns
    attr_reader :data
    attr_reader :stats
    attr_reader :error

    def initialize(options={})
      @id = options[:id]
      @info_uri = options[:info_uri]
      @partial_cancel_uri = options[:partial_cancel_uri]
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
        partial_cancel_uri: hash["partialCancelUri"],
        next_uri: hash["nextUri"],
        columns: hash["columns"] && hash["columns"].map {|h| Column.decode_hash(h) },
        data: hash["data"],
        stats: hash["stats"] && StatementStats.decode_hash(hash["stats"]),
        error: hash["error"] && QueryError.decode_hash(hash["error"]),
      )
    end
  end

  class QueryStats
    attr_reader :create_time
    attr_reader :execution_start_time
    attr_reader :last_heartbeat
    attr_reader :end_time
    attr_reader :elapsed_time
    attr_reader :queued_time
    attr_reader :analysis_time
    attr_reader :distributed_planning_time
    attr_reader :total_planning_time
    attr_reader :total_tasks
    attr_reader :running_tasks
    attr_reader :completed_tasks
    attr_reader :total_drivers
    attr_reader :queued_drivers
    attr_reader :running_drivers
    attr_reader :completed_drivers
    attr_reader :total_memory_reservation
    attr_reader :total_scheduled_time
    attr_reader :total_cpu_time
    attr_reader :total_user_time
    attr_reader :total_blocked_time
    attr_reader :raw_input_data_size
    attr_reader :raw_input_positions
    attr_reader :processed_input_data_size
    attr_reader :processed_input_positions
    attr_reader :output_data_size
    attr_reader :output_positions

    def initialize(options={})
      @create_time = options[:create_time]
      @execution_start_time = options[:execution_start_time]
      @last_heartbeat = options[:last_heartbeat]
      @end_time = options[:end_time]
      @elapsed_time = options[:elapsed_time]
      @queued_time = options[:queued_time]
      @analysis_time = options[:analysis_time]
      @distributed_planning_time = options[:distributed_planning_time]
      @total_planning_time = options[:total_planning_time]
      @total_tasks = options[:total_tasks]
      @running_tasks = options[:running_tasks]
      @completed_tasks = options[:completed_tasks]
      @total_drivers = options[:total_drivers]
      @queued_drivers = options[:queued_drivers]
      @running_drivers = options[:running_drivers]
      @completed_drivers = options[:completed_drivers]
      @total_memory_reservation = options[:total_memory_reservation]
      @total_scheduled_time = options[:total_scheduled_time]
      @total_cpu_time = options[:total_cpu_time]
      @total_user_time = options[:total_user_time]
      @total_blocked_time = options[:total_blocked_time]
      @raw_input_data_size = options[:raw_input_data_size]
      @raw_input_positions = options[:raw_input_positions]
      @processed_input_data_size = options[:processed_input_data_size]
      @processed_input_positions = options[:processed_input_positions]
      @output_data_size = options[:output_data_size]
      @output_positions = options[:output_positions]
    end

    def self.decode_hash(hash)
      new(
        create_time: hash["createTime"],
        execution_start_time: hash["executionStartTime"],
        last_heartbeat: hash["lastHeartbeat"],
        end_time: hash["endTime"],
        elapsed_time: hash["elapsedTime"],
        queued_time: hash["queuedTime"],
        analysis_time: hash["analysisTime"],
        distributed_planning_time: hash["distributedPlanningTime"],
        total_planning_time: hash["totalPlanningTime"],
        total_tasks: hash["totalTasks"],
        running_tasks: hash["runningTasks"],
        completed_tasks: hash["completedTasks"],
        total_drivers: hash["totalDrivers"],
        queued_drivers: hash["queuedDrivers"],
        running_drivers: hash["runningDrivers"],
        completed_drivers: hash["completedDrivers"],
        total_memory_reservation: hash["totalMemoryReservation"],
        total_scheduled_time: hash["totalScheduledTime"],
        total_cpu_time: hash["totalCpuTime"],
        total_user_time: hash["totalUserTime"],
        total_blocked_time: hash["totalBlockedTime"],
        raw_input_data_size: hash["rawInputDataSize"],
        raw_input_positions: hash["rawInputPositions"],
        processed_input_data_size: hash["processedInputDataSize"],
        processed_input_positions: hash["processedInputPositions"],
        output_data_size: hash["outputDataSize"],
        output_positions: hash["outputPositions"],
      )
    end
  end

  class SampleNode
    attr_reader :id
    attr_reader :source
    attr_reader :sample_ratio
    attr_reader :sample_type
    attr_reader :rescaled
    attr_reader :sample_weight_symbol

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @sample_ratio = options[:sample_ratio]
      @sample_type = options[:sample_type]
      @rescaled = options[:rescaled]
      @sample_weight_symbol = options[:sample_weight_symbol]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        sample_ratio: hash["sampleRatio"],
        sample_type: hash["sampleType"],
        rescaled: hash["rescaled"],
        sample_weight_symbol: hash["sampleWeightSymbol"],
      )
    end
  end

  class SemiJoinNode
    attr_reader :id
    attr_reader :source
    attr_reader :filtering_source
    attr_reader :source_join_symbol
    attr_reader :filtering_source_join_symbol
    attr_reader :semi_join_output

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @filtering_source = options[:filtering_source]
      @source_join_symbol = options[:source_join_symbol]
      @filtering_source_join_symbol = options[:filtering_source_join_symbol]
      @semi_join_output = options[:semi_join_output]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        filtering_source: hash["filteringSource"] && PlanNode.decode_hash(hash["filteringSource"]),
        source_join_symbol: hash["sourceJoinSymbol"],
        filtering_source_join_symbol: hash["filteringSourceJoinSymbol"],
        semi_join_output: hash["semiJoinOutput"],
      )
    end
  end

  class SharedBufferInfo
    attr_reader :state
    attr_reader :master_sequence_id
    attr_reader :pages_added
    attr_reader :buffers

    def initialize(options={})
      @state = options[:state]
      @master_sequence_id = options[:master_sequence_id]
      @pages_added = options[:pages_added]
      @buffers = options[:buffers]
    end

    def self.decode_hash(hash)
      new(
        state: hash["state"] && hash["state"].downcase.to_sym,
        master_sequence_id: hash["masterSequenceId"],
        pages_added: hash["pagesAdded"],
        buffers: hash["buffers"] && hash["buffers"].map {|h| BufferInfo.decode_hash(h) },
      )
    end
  end

  class Signature
    attr_reader :name
    attr_reader :return_type
    attr_reader :argument_types
    attr_reader :approximate

    def initialize(options={})
      @name = options[:name]
      @return_type = options[:return_type]
      @argument_types = options[:argument_types]
      @approximate = options[:approximate]
    end

    def self.decode_hash(hash)
      new(
        name: hash["name"],
        return_type: hash["returnType"],
        argument_types: hash["argumentTypes"],
        approximate: hash["approximate"],
      )
    end
  end

  class SinkNode
    attr_reader :id
    attr_reader :source
    attr_reader :output_symbols

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @output_symbols = options[:output_symbols]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        output_symbols: hash["outputSymbols"],
      )
    end
  end

  class SortNode
    attr_reader :id
    attr_reader :source
    attr_reader :order_by
    attr_reader :orderings

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @order_by = options[:order_by]
      @orderings = options[:orderings]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        order_by: hash["orderBy"],
        orderings: hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
      )
    end
  end

  class StageInfo
    attr_reader :stage_id
    attr_reader :state
    attr_reader :self
    attr_reader :plan
    attr_reader :types
    attr_reader :stage_stats
    attr_reader :tasks
    attr_reader :sub_stages
    attr_reader :failures

    def initialize(options={})
      @stage_id = options[:stage_id]
      @state = options[:state]
      @self = options[:self]
      @plan = options[:plan]
      @types = options[:types]
      @stage_stats = options[:stage_stats]
      @tasks = options[:tasks]
      @sub_stages = options[:sub_stages]
      @failures = options[:failures]
    end

    def self.decode_hash(hash)
      new(
        stage_id: hash["stageId"] && StageId.new(hash["stageId"]),
        state: hash["state"] && hash["state"].downcase.to_sym,
        self: hash["self"],
        plan: hash["plan"] && PlanFragment.decode_hash(hash["plan"]),
        types: hash["types"],
        stage_stats: hash["stageStats"] && StageStats.decode_hash(hash["stageStats"]),
        tasks: hash["tasks"] && hash["tasks"].map {|h| TaskInfo.decode_hash(h) },
        sub_stages: hash["subStages"] && hash["subStages"].map {|h| StageInfo.decode_hash(h) },
        failures: hash["failures"] && hash["failures"].map {|h| ExecutionFailureInfo.decode_hash(h) },
      )
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

  class TableCommitNode
    attr_reader :id
    attr_reader :source
    attr_reader :target
    attr_reader :outputs

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @target = options[:target]
      @outputs = options[:outputs]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        target: hash["target"] && OutputTableHandle.decode_hash(hash["target"]),
        outputs: hash["outputs"],
      )
    end
  end

  class TableHandle
    attr_reader :connector_id
    attr_reader :connector_handle

    def initialize(options={})
      @connector_id = options[:connector_id]
      @connector_handle = options[:connector_handle]
    end

    def self.decode_hash(hash)
      new(
        connector_id: hash["connectorId"],
        connector_handle: hash["connectorHandle"],
      )
    end
  end

  class TableScanNode
    attr_reader :id
    attr_reader :table
    attr_reader :output_symbols
    attr_reader :assignments
    attr_reader :original_constraint

    def initialize(options={})
      @id = options[:id]
      @table = options[:table]
      @output_symbols = options[:output_symbols]
      @assignments = options[:assignments]
      @original_constraint = options[:original_constraint]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        table: hash["table"] && TableHandle.decode_hash(hash["table"]),
        output_symbols: hash["outputSymbols"],
        assignments: hash["assignments"] && Hash[hash["assignments"].to_a.map! {|k,v| [k, ColumnHandle.decode_hash(v)] }],
        original_constraint: hash["originalConstraint"],
      )
    end
  end

  class TableWriterNode
    attr_reader :id
    attr_reader :source
    attr_reader :target
    attr_reader :columns
    attr_reader :column_names
    attr_reader :outputs
    attr_reader :sample_weight_symbol

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @target = options[:target]
      @columns = options[:columns]
      @column_names = options[:column_names]
      @outputs = options[:outputs]
      @sample_weight_symbol = options[:sample_weight_symbol]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        target: hash["target"] && OutputTableHandle.decode_hash(hash["target"]),
        columns: hash["columns"],
        column_names: hash["columnNames"],
        outputs: hash["outputs"],
        sample_weight_symbol: hash["sampleWeightSymbol"],
      )
    end
  end

  class TaskInfo
    attr_reader :task_id
    attr_reader :version
    attr_reader :state
    attr_reader :self
    attr_reader :last_heartbeat
    attr_reader :output_buffers
    attr_reader :no_more_splits
    attr_reader :stats
    attr_reader :failures

    def initialize(options={})
      @task_id = options[:task_id]
      @version = options[:version]
      @state = options[:state]
      @self = options[:self]
      @last_heartbeat = options[:last_heartbeat]
      @output_buffers = options[:output_buffers]
      @no_more_splits = options[:no_more_splits]
      @stats = options[:stats]
      @failures = options[:failures]
    end

    def self.decode_hash(hash)
      new(
        task_id: hash["taskId"] && TaskId.new(hash["taskId"]),
        version: hash["version"],
        state: hash["state"] && hash["state"].downcase.to_sym,
        self: hash["self"],
        last_heartbeat: hash["lastHeartbeat"],
        output_buffers: hash["outputBuffers"] && SharedBufferInfo.decode_hash(hash["outputBuffers"]),
        no_more_splits: hash["noMoreSplits"] && hash["noMoreSplits"].map {|h| PlanNodeId.new(h) },
        stats: hash["stats"] && TaskStats.decode_hash(hash["stats"]),
        failures: hash["failures"] && hash["failures"].map {|h| ExecutionFailureInfo.decode_hash(h) },
      )
    end
  end

  class TaskStats
    attr_reader :create_time
    attr_reader :first_start_time
    attr_reader :last_start_time
    attr_reader :end_time
    attr_reader :elapsed_time
    attr_reader :queued_time
    attr_reader :total_drivers
    attr_reader :queued_drivers
    attr_reader :running_drivers
    attr_reader :completed_drivers
    attr_reader :memory_reservation
    attr_reader :total_scheduled_time
    attr_reader :total_cpu_time
    attr_reader :total_user_time
    attr_reader :total_blocked_time
    attr_reader :raw_input_data_size
    attr_reader :raw_input_positions
    attr_reader :processed_input_data_size
    attr_reader :processed_input_positions
    attr_reader :output_data_size
    attr_reader :output_positions
    attr_reader :pipelines

    def initialize(options={})
      @create_time = options[:create_time]
      @first_start_time = options[:first_start_time]
      @last_start_time = options[:last_start_time]
      @end_time = options[:end_time]
      @elapsed_time = options[:elapsed_time]
      @queued_time = options[:queued_time]
      @total_drivers = options[:total_drivers]
      @queued_drivers = options[:queued_drivers]
      @running_drivers = options[:running_drivers]
      @completed_drivers = options[:completed_drivers]
      @memory_reservation = options[:memory_reservation]
      @total_scheduled_time = options[:total_scheduled_time]
      @total_cpu_time = options[:total_cpu_time]
      @total_user_time = options[:total_user_time]
      @total_blocked_time = options[:total_blocked_time]
      @raw_input_data_size = options[:raw_input_data_size]
      @raw_input_positions = options[:raw_input_positions]
      @processed_input_data_size = options[:processed_input_data_size]
      @processed_input_positions = options[:processed_input_positions]
      @output_data_size = options[:output_data_size]
      @output_positions = options[:output_positions]
      @pipelines = options[:pipelines]
    end

    def self.decode_hash(hash)
      new(
        create_time: hash["createTime"],
        first_start_time: hash["firstStartTime"],
        last_start_time: hash["lastStartTime"],
        end_time: hash["endTime"],
        elapsed_time: hash["elapsedTime"],
        queued_time: hash["queuedTime"],
        total_drivers: hash["totalDrivers"],
        queued_drivers: hash["queuedDrivers"],
        running_drivers: hash["runningDrivers"],
        completed_drivers: hash["completedDrivers"],
        memory_reservation: hash["memoryReservation"],
        total_scheduled_time: hash["totalScheduledTime"],
        total_cpu_time: hash["totalCpuTime"],
        total_user_time: hash["totalUserTime"],
        total_blocked_time: hash["totalBlockedTime"],
        raw_input_data_size: hash["rawInputDataSize"],
        raw_input_positions: hash["rawInputPositions"],
        processed_input_data_size: hash["processedInputDataSize"],
        processed_input_positions: hash["processedInputPositions"],
        output_data_size: hash["outputDataSize"],
        output_positions: hash["outputPositions"],
        pipelines: hash["pipelines"] && hash["pipelines"].map {|h| PipelineStats.decode_hash(h) },
      )
    end
  end

  class TopNNode
    attr_reader :id
    attr_reader :source
    attr_reader :count
    attr_reader :order_by
    attr_reader :orderings
    attr_reader :partial
    attr_reader :sample_weight

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @count = options[:count]
      @order_by = options[:order_by]
      @orderings = options[:orderings]
      @partial = options[:partial]
      @sample_weight = options[:sample_weight]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        count: hash["count"],
        order_by: hash["orderBy"],
        orderings: hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
        partial: hash["partial"],
        sample_weight: hash["sampleWeight"],
      )
    end
  end

  class ValuesNode
    attr_reader :id
    attr_reader :output_symbols
    attr_reader :rows

    def initialize(options={})
      @id = options[:id]
      @output_symbols = options[:output_symbols]
      @rows = options[:rows]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        output_symbols: hash["outputSymbols"],
        rows: hash["rows"],
      )
    end
  end

  class WindowNode
    attr_reader :id
    attr_reader :source
    attr_reader :partition_by
    attr_reader :order_by
    attr_reader :orderings
    attr_reader :window_functions
    attr_reader :signatures

    def initialize(options={})
      @id = options[:id]
      @source = options[:source]
      @partition_by = options[:partition_by]
      @order_by = options[:order_by]
      @orderings = options[:orderings]
      @window_functions = options[:window_functions]
      @signatures = options[:signatures]
    end

    def self.decode_hash(hash)
      new(
        id: hash["id"] && PlanNodeId.new(hash["id"]),
        source: hash["source"] && PlanNode.decode_hash(hash["source"]),
        partition_by: hash["partitionBy"],
        order_by: hash["orderBy"],
        orderings: hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
        window_functions: hash["windowFunctions"],
        signatures: hash["signatures"] && Hash[hash["signatures"].to_a.map! {|k,v| [k, Signature.decode_hash(v)] }],
      )
    end
  end


end

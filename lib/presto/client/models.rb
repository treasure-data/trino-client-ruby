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

  module Models
    class Base < Struct
      class << self
        alias_method :new_struct, :new

        def new(*args)
          new_struct(*args) do
            # make it immutable
            undef_method :"[]="
            members.each do |m|
              undef_method :"#{m}="
            end

            # replace constructor to receive hash instead of array
            alias_method :initialize_struct, :initialize

            def initialize(params={})
              initialize_struct(*members.map {|m| params[m] })
            end
          end
        end
      end
    end

    class QueryId < String
    end

    class StageId < String
      def initialize(str)
        super
        splitted = split('.', 2)
        @query_id = QueryId.new(splitted[0])
        @id = QueryId.new(splitted[1])
      end

      attr_reader :query_id, :id
    end

    class TaskId < String
      def initialize(str)
        super
        splitted = split('.', 3)
        @stage_id = StageId.new("#{splitted[0]}.#{splitted[1]}")
        @query_id = @stage_id.query_id
        @id = splitted[2]
      end

      attr_reader :query_id, :stage_id, :id
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
      def self.decode(hash)
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
          when "remoteSource"       then RemoteSourceNode
          when "join"               then JoinNode
          when "INNER"              then JoinNode
          when "LEFT"               then JoinNode
          when "RIGHT"              then JoinNode
          when "CROSS"              then JoinNode
          when "semijoin"           then SemiJoinNode
          when "indexjoin"          then IndexJoinNode
          when "indexsource"        then IndexSourceNode
          when "tablewriter"        then TableWriterNode
          when "tablecommit"        then TableCommitNode
          end
        model_class.decode(hash) if model_class
      end
    end

    # io.airlift.stats.Distribution.DistributionSnapshot
    class << DistributionSnapshot =
        Base.new(:max_error, :count, :total, :p01, :p05, :p10, :p25, :p50, :p75, :p90, :p95, :p99, :min, :max)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["maxError"],
          hash["count"],
          hash["total"],
          hash["p01"],
          hash["p05"],
          hash["p10"],
          hash["p25"],
          hash["p50"],
          hash["p75"],
          hash["p90"],
          hash["p95"],
          hash["p99"],
          hash["min"],
          hash["max"],
        )
        obj
      end
    end

    class << EquiJoinClause =
        Base.new(:left, :right)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["left"],
          hash["right"],
        )
        obj
      end
    end

    class << WriterTarget =
        Base.new(:type, :handle)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["type"],
          hash["type"] == 'InsertHandle' ? InsertTableHandle.decode(hash['handle']) : OutputTableHandle.decode(hash['handle'])
        )
        obj
      end
    end

    ##
    # Those model classes are automatically generated
    #

    class << AggregationNode =
        Base.new(:id, :source, :group_by, :aggregations, :functions, :masks, :step, :sample_weight, :confidence, :hash_symbol)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["groupBy"],
          hash["aggregations"],
          hash["functions"] && Hash[hash["functions"].to_a.map! {|k,v| [k, Signature.decode(v)] }],
          hash["masks"],
          hash["step"] && hash["step"].downcase.to_sym,
          hash["sampleWeight"],
          hash["confidence"],
          hash["hashSymbol"],
        )
        obj
      end
    end

    class << BufferInfo =
        Base.new(:buffer_id, :finished, :buffered_pages, :pages_sent)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["bufferId"] && TaskId.new(hash["bufferId"]),
          hash["finished"],
          hash["bufferedPages"],
          hash["pagesSent"],
        )
        obj
      end
    end

    class << ClientTypeSignature =
        Base.new(:raw_type, :type_arguments, :literal_arguments)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["rawType"],
          hash["typeArguments"] && hash["typeArguments"].map {|h| ClientTypeSignature.decode(h) },
          hash["literalArguments"],
        )
        obj
      end
    end

    class << Column =
        Base.new(:name, :type, :type_signature)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["name"],
          hash["type"],
          hash["typeSignature"] && ClientTypeSignature.decode(hash["typeSignature"]),
        )
        obj
      end
    end

    class << ColumnHandle =
        Base.new(:connector_id, :connector_handle)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << DistinctLimitNode =
        Base.new(:id, :source, :limit, :hash_symbol)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["limit"],
          hash["hashSymbol"],
        )
        obj
      end
    end

    class << DriverStats =
        Base.new(:create_time, :start_time, :end_time, :queued_time, :elapsed_time, :memory_reservation, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :raw_input_data_size, :raw_input_positions, :raw_input_read_time, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :operator_stats)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["createTime"],
          hash["startTime"],
          hash["endTime"],
          hash["queuedTime"],
          hash["elapsedTime"],
          hash["memoryReservation"],
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalUserTime"],
          hash["totalBlockedTime"],
          hash["rawInputDataSize"],
          hash["rawInputPositions"],
          hash["rawInputReadTime"],
          hash["processedInputDataSize"],
          hash["processedInputPositions"],
          hash["outputDataSize"],
          hash["outputPositions"],
          hash["operatorStats"] && hash["operatorStats"].map {|h| OperatorStats.decode(h) },
        )
        obj
      end
    end

    class << ErrorCode =
        Base.new(:code, :name)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["code"],
          hash["name"],
        )
        obj
      end
    end

    class << ErrorLocation =
        Base.new(:line_number, :column_number)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["lineNumber"],
          hash["columnNumber"],
        )
        obj
      end
    end

    class << ExchangeNode =
        Base.new(:id, :type, :partition_keys, :hash_symbol, :sources, :outputs, :inputs)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["type"],
          hash["partitionKeys"],
          hash["hashSymbol"],
          hash["sources"] && hash["sources"].map {|h| PlanNode.decode(h) },
          hash["outputs"],
          hash["inputs"],
        )
        obj
      end
    end

    class << ExecutionFailureInfo =
        Base.new(:type, :message, :cause, :suppressed, :stack, :error_location, :error_code)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["type"],
          hash["message"],
          hash["cause"] && ExecutionFailureInfo.decode(hash["cause"]),
          hash["suppressed"] && hash["suppressed"].map {|h| ExecutionFailureInfo.decode(h) },
          hash["stack"],
          hash["errorLocation"] && ErrorLocation.decode(hash["errorLocation"]),
          hash["errorCode"] && ErrorCode.decode(hash["errorCode"]),
        )
        obj
      end
    end

    class << FailureInfo =
        Base.new(:type, :message, :cause, :suppressed, :stack, :error_location)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["type"],
          hash["message"],
          hash["cause"] && FailureInfo.decode(hash["cause"]),
          hash["suppressed"] && hash["suppressed"].map {|h| FailureInfo.decode(h) },
          hash["stack"],
          hash["errorLocation"] && ErrorLocation.decode(hash["errorLocation"]),
        )
        obj
      end
    end

    class << FilterNode =
        Base.new(:id, :source, :predicate)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["predicate"],
        )
        obj
      end
    end

    class << IndexHandle =
        Base.new(:connector_id, :connector_handle)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << IndexJoinNode =
        Base.new(:id, :type, :probe_source, :index_source, :criteria, :probe_hash_symbol, :index_hash_symbol)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["type"],
          hash["probeSource"] && PlanNode.decode(hash["probeSource"]),
          hash["indexSource"] && PlanNode.decode(hash["indexSource"]),
          hash["criteria"] && hash["criteria"].map {|h| EquiJoinClause.decode(h) },
          hash["probeHashSymbol"],
          hash["indexHashSymbol"],
        )
        obj
      end
    end

    class << IndexSourceNode =
        Base.new(:id, :index_handle, :table_handle, :lookup_symbols, :output_symbols, :assignments, :effective_tuple_domain)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["indexHandle"] && IndexHandle.decode(hash["indexHandle"]),
          hash["tableHandle"] && TableHandle.decode(hash["tableHandle"]),
          hash["lookupSymbols"],
          hash["outputSymbols"],
          hash["assignments"] && Hash[hash["assignments"].to_a.map! {|k,v| [k, ColumnHandle.decode(v)] }],
        )
        obj
      end
    end

    class << Input =
        Base.new(:connector_id, :schema, :table, :columns)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["schema"],
          hash["table"],
          hash["columns"] && hash["columns"].map {|h| Column.decode(h) },
        )
        obj
      end
    end

    class << InsertTableHandle =
        Base.new(:connector_id, :connector_handle)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << JoinNode =
        Base.new(:id, :type, :left, :right, :criteria, :left_hash_symbol, :right_hash_symbol)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["type"],
          hash["left"] && PlanNode.decode(hash["left"]),
          hash["right"] && PlanNode.decode(hash["right"]),
          hash["criteria"] && hash["criteria"].map {|h| EquiJoinClause.decode(h) },
          hash["leftHashSymbol"],
          hash["rightHashSymbol"],
        )
        obj
      end
    end

    class << LimitNode =
        Base.new(:id, :source, :count)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["count"],
        )
        obj
      end
    end

    class << MarkDistinctNode =
        Base.new(:id, :source, :marker_symbol, :distinct_symbols, :hash_symbol)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["markerSymbol"],
          hash["distinctSymbols"],
          hash["hashSymbol"],
        )
        obj
      end
    end

    class << OperatorStats =
        Base.new(:operator_id, :operator_type, :add_input_calls, :add_input_wall, :add_input_cpu, :add_input_user, :input_data_size, :input_positions, :get_output_calls, :get_output_wall, :get_output_cpu, :get_output_user, :output_data_size, :output_positions, :blocked_wall, :finish_calls, :finish_wall, :finish_cpu, :finish_user, :memory_reservation, :info)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["operatorId"],
          hash["operatorType"],
          hash["addInputCalls"],
          hash["addInputWall"],
          hash["addInputCpu"],
          hash["addInputUser"],
          hash["inputDataSize"],
          hash["inputPositions"],
          hash["getOutputCalls"],
          hash["getOutputWall"],
          hash["getOutputCpu"],
          hash["getOutputUser"],
          hash["outputDataSize"],
          hash["outputPositions"],
          hash["blockedWall"],
          hash["finishCalls"],
          hash["finishWall"],
          hash["finishCpu"],
          hash["finishUser"],
          hash["memoryReservation"],
          hash["info"],
        )
        obj
      end
    end

    class << OutputNode =
        Base.new(:id, :source, :columns, :outputs)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["columns"],
          hash["outputs"],
        )
        obj
      end
    end

    class << OutputTableHandle =
        Base.new(:connector_id, :connector_handle)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << PipelineStats =
        Base.new(:input_pipeline, :output_pipeline, :total_drivers, :queued_drivers, :queued_partitioned_drivers, :running_drivers, :running_partitioned_drivers, :completed_drivers, :memory_reservation, :queued_time, :elapsed_time, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :operator_summaries, :drivers)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["inputPipeline"],
          hash["outputPipeline"],
          hash["totalDrivers"],
          hash["queuedDrivers"],
          hash["queuedPartitionedDrivers"],
          hash["runningDrivers"],
          hash["runningPartitionedDrivers"],
          hash["completedDrivers"],
          hash["memoryReservation"],
          hash["queuedTime"] && DistributionSnapshot.decode(hash["queuedTime"]),
          hash["elapsedTime"] && DistributionSnapshot.decode(hash["elapsedTime"]),
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalUserTime"],
          hash["totalBlockedTime"],
          hash["rawInputDataSize"],
          hash["rawInputPositions"],
          hash["processedInputDataSize"],
          hash["processedInputPositions"],
          hash["outputDataSize"],
          hash["outputPositions"],
          hash["operatorSummaries"] && hash["operatorSummaries"].map {|h| OperatorStats.decode(h) },
          hash["drivers"] && hash["drivers"].map {|h| DriverStats.decode(h) },
        )
        obj
      end
    end

    class << PlanFragment =
        Base.new(:id, :root, :symbols, :output_layout, :distribution, :partitioned_source, :output_partitioning, :partition_by, :hash)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanFragmentId.new(hash["id"]),
          hash["root"] && PlanNode.decode(hash["root"]),
          hash["symbols"],
          hash["outputLayout"],
          hash["distribution"] && hash["distribution"].downcase.to_sym,
          hash["partitionedSource"] && PlanNodeId.new(hash["partitionedSource"]),
          hash["outputPartitioning"] && hash["outputPartitioning"].downcase.to_sym,
          hash["partitionBy"],
          hash["hash"],
        )
        obj
      end
    end

    class << ProjectNode =
        Base.new(:id, :source, :assignments)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["assignments"],
        )
        obj
      end
    end

    class << QueryError =
        Base.new(:message, :sql_state, :error_code, :error_location, :failure_info)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["message"],
          hash["sqlState"],
          hash["errorCode"],
          hash["errorLocation"] && ErrorLocation.decode(hash["errorLocation"]),
          hash["failureInfo"] && FailureInfo.decode(hash["failureInfo"]),
        )
        obj
      end
    end

    class << QueryInfo =
        Base.new(:query_id, :session, :state, :scheduled, :self, :field_names, :query, :query_stats, :set_session_properties, :reset_session_properties, :update_type, :output_stage, :failure_info, :error_code, :inputs)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["queryId"] && QueryId.new(hash["queryId"]),
          hash["session"] && Session.decode(hash["session"]),
          hash["state"] && hash["state"].downcase.to_sym,
          hash["scheduled"],
          hash["self"],
          hash["fieldNames"],
          hash["query"],
          hash["queryStats"] && QueryStats.decode(hash["queryStats"]),
          hash["setSessionProperties"],
          hash["resetSessionProperties"],
          hash["updateType"],
          hash["outputStage"] && StageInfo.decode(hash["outputStage"]),
          hash["failureInfo"] && FailureInfo.decode(hash["failureInfo"]),
          hash["errorCode"] && ErrorCode.decode(hash["errorCode"]),
          hash["inputs"] && hash["inputs"].map {|h| Input.decode(h) },
        )
        obj
      end
    end

    class << QueryResults =
        Base.new(:id, :info_uri, :partial_cancel_uri, :next_uri, :columns, :data, :stats, :error, :update_type, :update_count)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["infoUri"],
          hash["partialCancelUri"],
          hash["nextUri"],
          hash["columns"] && hash["columns"].map {|h| Column.decode(h) },
          hash["data"],
          hash["stats"] && StatementStats.decode(hash["stats"]),
          hash["error"] && QueryError.decode(hash["error"]),
          hash["updateType"],
          hash["updateCount"],
        )
        obj
      end
    end

    class << QueryStats =
        Base.new(:create_time, :execution_start_time, :last_heartbeat, :end_time, :elapsed_time, :queued_time, :analysis_time, :distributed_planning_time, :total_planning_time, :total_tasks, :running_tasks, :completed_tasks, :total_drivers, :queued_drivers, :running_drivers, :completed_drivers, :total_memory_reservation, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["createTime"],
          hash["executionStartTime"],
          hash["lastHeartbeat"],
          hash["endTime"],
          hash["elapsedTime"],
          hash["queuedTime"],
          hash["analysisTime"],
          hash["distributedPlanningTime"],
          hash["totalPlanningTime"],
          hash["totalTasks"],
          hash["runningTasks"],
          hash["completedTasks"],
          hash["totalDrivers"],
          hash["queuedDrivers"],
          hash["runningDrivers"],
          hash["completedDrivers"],
          hash["totalMemoryReservation"],
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalUserTime"],
          hash["totalBlockedTime"],
          hash["rawInputDataSize"],
          hash["rawInputPositions"],
          hash["processedInputDataSize"],
          hash["processedInputPositions"],
          hash["outputDataSize"],
          hash["outputPositions"],
        )
        obj
      end
    end

    class << RemoteSourceNode =
        Base.new(:id, :source_fragment_ids, :outputs)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["sourceFragmentIds"] && hash["sourceFragmentIds"].map {|h| PlanFragmentId.new(h) },
          hash["outputs"],
        )
        obj
      end
    end

    class << SampleNode =
        Base.new(:id, :source, :sample_ratio, :sample_type, :rescaled, :sample_weight_symbol)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["sampleRatio"],
          hash["sampleType"],
          hash["rescaled"],
          hash["sampleWeightSymbol"],
        )
        obj
      end
    end

    class << SemiJoinNode =
        Base.new(:id, :source, :filtering_source, :source_join_symbol, :filtering_source_join_symbol, :semi_join_output, :source_hash_symbol, :filtering_source_hash_symbol)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["filteringSource"] && PlanNode.decode(hash["filteringSource"]),
          hash["sourceJoinSymbol"],
          hash["filteringSourceJoinSymbol"],
          hash["semiJoinOutput"],
          hash["sourceHashSymbol"],
          hash["filteringSourceHashSymbol"],
        )
        obj
      end
    end

    class << Session =
        Base.new(:user, :source, :catalog, :schema, :time_zone_key, :locale, :remote_user_address, :user_agent, :start_time, :system_properties, :catalog_properties)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["user"],
          hash["source"],
          hash["catalog"],
          hash["schema"],
          hash["timeZoneKey"],
          hash["locale"],
          hash["remoteUserAddress"],
          hash["userAgent"],
          hash["startTime"],
          hash["systemProperties"],
          hash["catalogProperties"],
        )
        obj
      end
    end

    class << SharedBufferInfo =
        Base.new(:state, :master_sequence_id, :pages_added, :buffers)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["state"] && hash["state"].downcase.to_sym,
          hash["masterSequenceId"],
          hash["pagesAdded"],
          hash["buffers"] && hash["buffers"].map {|h| BufferInfo.decode(h) },
        )
        obj
      end
    end

    class << Signature =
        Base.new(:name, :type_parameters, :return_type, :argument_types, :variable_arity, :internal)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["name"],
          hash["typeParameters"] && hash["typeParameters"].map {|h| TypeParameter.decode(h) },
          hash["returnType"],
          hash["argumentTypes"],
          hash["variableArity"],
          hash["internal"],
        )
        obj
      end
    end

    class << SortNode =
        Base.new(:id, :source, :order_by, :orderings)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["orderBy"],
          hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
        )
        obj
      end
    end

    class << StageInfo =
        Base.new(:stage_id, :state, :self, :plan, :types, :stage_stats, :tasks, :sub_stages, :failures)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["stageId"] && StageId.new(hash["stageId"]),
          hash["state"] && hash["state"].downcase.to_sym,
          hash["self"],
          hash["plan"] && PlanFragment.decode(hash["plan"]),
          hash["types"],
          hash["stageStats"] && StageStats.decode(hash["stageStats"]),
          hash["tasks"] && hash["tasks"].map {|h| TaskInfo.decode(h) },
          hash["subStages"] && hash["subStages"].map {|h| StageInfo.decode(h) },
          hash["failures"] && hash["failures"].map {|h| ExecutionFailureInfo.decode(h) },
        )
        obj
      end
    end

    class << StageStats =
        Base.new(:stage_id, :state, :done, :nodes, :total_splits, :queued_splits, :running_splits, :completed_splits, :user_time_millis, :cpu_time_millis, :wall_time_millis, :processed_rows, :processed_bytes, :sub_stages)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["stageId"],
          hash["state"],
          hash["done"],
          hash["nodes"],
          hash["totalSplits"],
          hash["queuedSplits"],
          hash["runningSplits"],
          hash["completedSplits"],
          hash["userTimeMillis"],
          hash["cpuTimeMillis"],
          hash["wallTimeMillis"],
          hash["processedRows"],
          hash["processedBytes"],
          hash["subStages"] && hash["subStages"].map {|h| StageStats.decode(h) },
        )
        obj
      end
    end

    class << StatementStats =
        Base.new(:state, :scheduled, :nodes, :total_splits, :queued_splits, :running_splits, :completed_splits, :user_time_millis, :cpu_time_millis, :wall_time_millis, :processed_rows, :processed_bytes, :root_stage)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["state"],
          hash["scheduled"],
          hash["nodes"],
          hash["totalSplits"],
          hash["queuedSplits"],
          hash["runningSplits"],
          hash["completedSplits"],
          hash["userTimeMillis"],
          hash["cpuTimeMillis"],
          hash["wallTimeMillis"],
          hash["processedRows"],
          hash["processedBytes"],
          hash["rootStage"] && StageStats.decode(hash["rootStage"]),
        )
        obj
      end
    end

    class << TableCommitNode =
        Base.new(:id, :source, :target, :outputs)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["target"] && WriterTarget.decode(hash["target"]),
          hash["outputs"],
        )
        obj
      end
    end

    class << TableHandle =
        Base.new(:connector_id, :connector_handle)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << TableScanNode =
        Base.new(:id, :table, :output_symbols, :assignments, :original_constraint)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["table"] && TableHandle.decode(hash["table"]),
          hash["outputSymbols"],
          hash["assignments"] && Hash[hash["assignments"].to_a.map! {|k,v| [k, ColumnHandle.decode(v)] }],
          hash["originalConstraint"],
        )
        obj
      end
    end

    class << TableWriterNode =
        Base.new(:id, :source, :target, :columns, :column_names, :outputs, :sample_weight_symbol)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["target"] && WriterTarget.decode(hash["target"]),
          hash["columns"],
          hash["columnNames"],
          hash["outputs"],
          hash["sampleWeightSymbol"],
        )
        obj
      end
    end

    class << TaskInfo =
        Base.new(:task_id, :node_instance_id, :version, :state, :self, :last_heartbeat, :output_buffers, :no_more_splits, :stats, :failures)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["taskId"] && TaskId.new(hash["taskId"]),
          hash["nodeInstanceId"],
          hash["version"],
          hash["state"] && hash["state"].downcase.to_sym,
          hash["self"],
          hash["lastHeartbeat"],
          hash["outputBuffers"] && SharedBufferInfo.decode(hash["outputBuffers"]),
          hash["noMoreSplits"] && hash["noMoreSplits"].map {|h| PlanNodeId.new(h) },
          hash["stats"] && TaskStats.decode(hash["stats"]),
          hash["failures"] && hash["failures"].map {|h| ExecutionFailureInfo.decode(h) },
        )
        obj
      end
    end

    class << TaskStats =
        Base.new(:create_time, :first_start_time, :last_start_time, :end_time, :elapsed_time, :queued_time, :total_drivers, :queued_drivers, :queued_partitioned_drivers, :running_drivers, :running_partitioned_drivers, :completed_drivers, :memory_reservation, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :pipelines)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["createTime"],
          hash["firstStartTime"],
          hash["lastStartTime"],
          hash["endTime"],
          hash["elapsedTime"],
          hash["queuedTime"],
          hash["totalDrivers"],
          hash["queuedDrivers"],
          hash["queuedPartitionedDrivers"],
          hash["runningDrivers"],
          hash["runningPartitionedDrivers"],
          hash["completedDrivers"],
          hash["memoryReservation"],
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalUserTime"],
          hash["totalBlockedTime"],
          hash["rawInputDataSize"],
          hash["rawInputPositions"],
          hash["processedInputDataSize"],
          hash["processedInputPositions"],
          hash["outputDataSize"],
          hash["outputPositions"],
          hash["pipelines"] && hash["pipelines"].map {|h| PipelineStats.decode(h) },
        )
        obj
      end
    end

    class << TopNNode =
        Base.new(:id, :source, :count, :order_by, :orderings, :partial)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["count"],
          hash["orderBy"],
          hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
          hash["partial"],
        )
        obj
      end
    end

    class << TypeParameter =
        Base.new(:name, :comparable_required, :orderable_required, :variadic_bound)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["name"],
          hash["comparableRequired"],
          hash["orderableRequired"],
          hash["variadicBound"],
        )
        obj
      end
    end

    class << ValuesNode =
        Base.new(:id, :output_symbols, :rows)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["outputSymbols"],
          hash["rows"],
        )
        obj
      end
    end

    class << WindowNode =
        Base.new(:id, :source, :partition_by, :order_by, :orderings, :frame, :window_functions, :signatures, :hash_symbol)
      def decode(hash)
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"] && PlanNodeId.new(hash["id"]),
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["partitionBy"],
          hash["orderBy"],
          hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
          hash["frame"],
          hash["windowFunctions"],
          hash["signatures"] && Hash[hash["signatures"].to_a.map! {|k,v| [k, Signature.decode(v)] }],
          hash["hashSymbol"],
        )
        obj
      end
    end


  end
end

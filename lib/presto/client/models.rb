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

    class StageId < String
      def initialize(str)
        super
        splitted = split('.', 2)
        @query_id = splitted[0]
        @id = splitted[1]
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

    class ConnectorSession < Hash
      def initialize(hash)
        super()
        merge!(hash)
      end
    end

    module PlanNode
      def self.decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        model_class = case hash["@type"]
          when "output"             then OutputNode
          when "project"            then ProjectNode
          when "tablescan"          then TableScanNode
          when "values"             then ValuesNode
          when "aggregation"        then AggregationNode
          when "markDistinct"       then MarkDistinctNode
          when "filter"             then FilterNode
          when "window"             then WindowNode
          when "rowNumber"          then RowNumberNode
          when "topnRowNumber"      then TopNRowNumberNode
          when "limit"              then LimitNode
          when "distinctlimit"      then DistinctLimitNode
          when "topn"               then TopNNode
          when "sample"             then SampleNode
          when "sort"               then SortNode
          when "remoteSource"       then RemoteSourceNode
          when "join"               then JoinNode
          when "semijoin"           then SemiJoinNode
          when "indexjoin"          then IndexJoinNode
          when "indexsource"        then IndexSourceNode
          when "tablewriter"        then TableWriterNode
          when "delete"             then DeleteNode
          when "metadatadelete"     then MetadataDeleteNode
          when "tablecommit"        then TableFinishNode
          when "unnest"             then UnnestNode
          when "exchange"           then ExchangeNode
          when "union"              then UnionNode
          when "scalar"             then EnforceSingleRowNode
        end
        if model_class
           node = model_class.decode(hash)
           class << node
             attr_accessor :plan_node_type
           end
           node.plan_node_type = hash['@type']
           node
        end
      end
    end

    # io.airlift.stats.Distribution.DistributionSnapshot
    class << DistributionSnapshot =
        Base.new(:max_error, :count, :total, :p01, :p05, :p10, :p25, :p50, :p75, :p90, :p95, :p99, :min, :max)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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

    # This is a hybrid of JoinNode.EquiJoinClause and IndexJoinNode.EquiJoinClause
    class << EquiJoinClause =
        Base.new(:left, :right, :probe, :index)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["left"],
          hash["right"],
          hash["probe"],
          hash["index"],
        )
        obj
      end
    end

    class << WriterTarget =
        Base.new(:type, :handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        model_class = case hash["@type"]
            when "CreateHandle"       then OutputTableHandle
            when "InsertHandle"       then InsertTableHandle
            when "DeleteHandle"       then TableHandle
        end
        obj.send(:initialize_struct,
          hash["@type"],
          model_class.decode(hash['handle'])
        )
        obj
      end
    end

    class << DeleteHandle =
        Base.new(:handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          TableHandle.decode(hash['handle'])
        )
        obj
      end
    end


    # A missing JsonCreator in Presto
    class << PageBufferInfo =
        Base.new(:partition, :buffered_pages, :queued_pages, :buffered_bytes, :pages_added)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["partition"],
          hash["bufferedPages"],
          hash["queuedPages"],
          hash["bufferedBytes"],
          hash["pagesAdded"],
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
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
        Base.new(:buffer_id, :finished, :buffered_pages, :pages_sent, :page_buffer_info)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["bufferId"] && TaskId.new(hash["bufferId"]),
          hash["finished"],
          hash["bufferedPages"],
          hash["pagesSent"],
          hash["pageBufferInfo"] && PageBufferInfo.decode(hash["pageBufferInfo"]),
        )
        obj
      end
    end

    class << ClientColumn =
        Base.new(:name, :type, :type_signature)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["name"],
          hash["type"],
          hash["typeSignature"] && ClientTypeSignature.decode(hash["typeSignature"]),
        )
        obj
      end
    end

    class << ClientStageStats =
        Base.new(:stage_id, :state, :done, :nodes, :total_splits, :queued_splits, :running_splits, :completed_splits, :user_time_millis, :cpu_time_millis, :wall_time_millis, :processed_rows, :processed_bytes, :sub_stages)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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
          hash["subStages"] && hash["subStages"].map {|h| ClientStageStats.decode(h) },
        )
        obj
      end
    end

    class << ClientTypeSignature =
        Base.new(:raw_type, :type_arguments, :literal_arguments, :arguments)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["rawType"],
          hash["typeArguments"] && hash["typeArguments"].map {|h| ClientTypeSignature.decode(h) },
          hash["literalArguments"],
          hash["arguments"] && hash["arguments"].map {|h| ClientTypeSignatureParameter.decode(h) },
        )
        obj
      end
    end

    class << ClientTypeSignatureParameter =
        Base.new(:kind, :value)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["kind"] && hash["kind"].downcase.to_sym,
          hash["value"],
        )
        obj
      end
    end

    class << Column =
        Base.new(:name, :type)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["name"],
          hash["type"],
        )
        obj
      end
    end

    class << DeleteNode =
        Base.new(:id, :source, :target, :row_id, :outputs)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["target"] && DeleteHandle.decode(hash["target"]),
          hash["rowId"],
          hash["outputs"],
        )
        obj
      end
    end

    class << DistinctLimitNode =
        Base.new(:id, :source, :limit, :hash_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["limit"],
          hash["hashSymbol"],
        )
        obj
      end
    end

    class << DriverStats =
        Base.new(:create_time, :start_time, :end_time, :queued_time, :elapsed_time, :memory_reservation, :system_memory_reservation, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :raw_input_data_size, :raw_input_positions, :raw_input_read_time, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :operator_stats)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["createTime"],
          hash["startTime"],
          hash["endTime"],
          hash["queuedTime"],
          hash["elapsedTime"],
          hash["memoryReservation"],
          hash["systemMemoryReservation"],
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalUserTime"],
          hash["totalBlockedTime"],
          hash["fullyBlocked"],
          hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
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

    class << EnforceSingleRowNode =
        Base.new(:id, :source)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
        )
        obj
      end
    end

    class << ErrorCode =
        Base.new(:code, :name)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["lineNumber"],
          hash["columnNumber"],
        )
        obj
      end
    end

    class << ExchangeNode =
        Base.new(:id, :type, :partition_function, :sources, :outputs, :inputs)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["type"],
          hash["partitionFunction"] && PartitionFunctionBinding.decode(hash["partitionFunction"]),
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["predicate"],
        )
        obj
      end
    end

    class << IndexHandle =
        Base.new(:connector_id, :transaction_handle, :connector_handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["transactionHandle"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << IndexJoinNode =
        Base.new(:id, :type, :probe_source, :index_source, :criteria, :probe_hash_symbol, :index_hash_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["indexHandle"] && IndexHandle.decode(hash["indexHandle"]),
          hash["tableHandle"] && TableHandle.decode(hash["tableHandle"]),
          hash["lookupSymbols"],
          hash["outputSymbols"],
          hash["assignments"],
          hash["effectiveTupleDomain"],
        )
        obj
      end
    end

    class << Input =
        Base.new(:connector_id, :schema, :table, :columns)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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
        Base.new(:connector_id, :transaction_handle, :connector_handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["transactionHandle"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << JoinNode =
        Base.new(:id, :type, :left, :right, :criteria, :left_hash_symbol, :right_hash_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["count"],
        )
        obj
      end
    end

    class << MarkDistinctNode =
        Base.new(:id, :source, :marker_symbol, :distinct_symbols, :hash_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["markerSymbol"],
          hash["distinctSymbols"],
          hash["hashSymbol"],
        )
        obj
      end
    end

    class << MetadataDeleteNode =
        Base.new(:id, :target, :output, :table_layout)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["target"] && DeleteHandle.decode(hash["target"]),
          hash["output"],
          hash["tableLayout"] && TableLayoutHandle.decode(hash["tableLayout"]),
        )
        obj
      end
    end

    class << OperatorStats =
        Base.new(:operator_id, :plan_node_id, :operator_type, :add_input_calls, :add_input_wall, :add_input_cpu, :add_input_user, :input_data_size, :input_positions, :get_output_calls, :get_output_wall, :get_output_cpu, :get_output_user, :output_data_size, :output_positions, :blocked_wall, :finish_calls, :finish_wall, :finish_cpu, :finish_user, :memory_reservation, :system_memory_reservation, :blocked_reason, :info)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["operatorId"],
          hash["planNodeId"],
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
          hash["systemMemoryReservation"],
          hash["blockedReason"] && BlockedReason.decode(hash["blockedReason"]),
          hash["info"],
        )
        obj
      end
    end

    class << OutputNode =
        Base.new(:id, :source, :columns, :outputs)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["columns"],
          hash["outputs"],
        )
        obj
      end
    end

    class << OutputTableHandle =
        Base.new(:connector_id, :transaction_handle, :connector_handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["transactionHandle"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << PartitionFunctionBinding =
        Base.new(:function_handle, :partitioning_columns, :hash_column, :replicate_nulls, :partition_count)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["functionHandle"] && hash["functionHandle"].downcase.to_sym,
          hash["partitioningColumns"],
          hash["hashColumn"],
          hash["replicateNulls"],
          hash["partitionCount"],
        )
        obj
      end
    end

    class << PipelineStats =
        Base.new(:input_pipeline, :output_pipeline, :total_drivers, :queued_drivers, :queued_partitioned_drivers, :running_drivers, :running_partitioned_drivers, :completed_drivers, :memory_reservation, :system_memory_reservation, :queued_time, :elapsed_time, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :operator_summaries, :drivers)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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
          hash["systemMemoryReservation"],
          hash["queuedTime"] && DistributionSnapshot.decode(hash["queuedTime"]),
          hash["elapsedTime"] && DistributionSnapshot.decode(hash["elapsedTime"]),
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalUserTime"],
          hash["totalBlockedTime"],
          hash["fullyBlocked"],
          hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
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
        Base.new(:id, :root, :symbols, :output_layout, :distribution, :partitioned_source, :partition_function)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["root"] && PlanNode.decode(hash["root"]),
          hash["symbols"],
          hash["outputLayout"],
          hash["distribution"] && hash["distribution"].downcase.to_sym,
          hash["partitionedSource"],
          hash["partitionFunction"] && PartitionFunctionBinding.decode(hash["partitionFunction"]),
        )
        obj
      end
    end

    class << ProjectNode =
        Base.new(:id, :source, :assignments)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["assignments"],
        )
        obj
      end
    end

    class << QueryError =
        Base.new(:message, :sql_state, :error_code, :error_name, :error_type, :error_location, :failure_info)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["message"],
          hash["sqlState"],
          hash["errorCode"],
          hash["errorName"],
          hash["errorType"],
          hash["errorLocation"] && ErrorLocation.decode(hash["errorLocation"]),
          hash["failureInfo"] && FailureInfo.decode(hash["failureInfo"]),
        )
        obj
      end
    end

    class << QueryInfo =
        Base.new(:query_id, :session, :state, :memory_pool, :scheduled, :self, :field_names, :query, :query_stats, :set_session_properties, :reset_session_properties, :started_transaction_id, :clear_transaction_id, :update_type, :output_stage, :failure_info, :error_code, :inputs)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["queryId"],
          hash["session"] && SessionRepresentation.decode(hash["session"]),
          hash["state"] && hash["state"].downcase.to_sym,
          hash["memoryPool"],
          hash["scheduled"],
          hash["self"],
          hash["fieldNames"],
          hash["query"],
          hash["queryStats"] && QueryStats.decode(hash["queryStats"]),
          hash["setSessionProperties"],
          hash["resetSessionProperties"],
          hash["startedTransactionId"],
          hash["clearTransactionId"],
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["infoUri"],
          hash["partialCancelUri"],
          hash["nextUri"],
          hash["columns"] && hash["columns"].map {|h| ClientColumn.decode(h) },
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
        Base.new(:create_time, :execution_start_time, :last_heartbeat, :end_time, :elapsed_time, :queued_time, :analysis_time, :distributed_planning_time, :total_planning_time, :finishing_time, :total_tasks, :running_tasks, :completed_tasks, :total_drivers, :queued_drivers, :running_drivers, :completed_drivers, :cumulative_memory, :total_memory_reservation, :peak_memory_reservation, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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
          hash["finishingTime"],
          hash["totalTasks"],
          hash["runningTasks"],
          hash["completedTasks"],
          hash["totalDrivers"],
          hash["queuedDrivers"],
          hash["runningDrivers"],
          hash["completedDrivers"],
          hash["cumulativeMemory"],
          hash["totalMemoryReservation"],
          hash["peakMemoryReservation"],
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalUserTime"],
          hash["totalBlockedTime"],
          hash["fullyBlocked"],
          hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["sourceFragmentIds"],
          hash["outputs"],
        )
        obj
      end
    end

    class << RowNumberNode =
        Base.new(:id, :source, :partition_by, :row_number_symbol, :max_row_count_per_partition, :hash_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["partitionBy"],
          hash["rowNumberSymbol"],
          hash["maxRowCountPerPartition"],
          hash["hashSymbol"],
        )
        obj
      end
    end

    class << SampleNode =
        Base.new(:id, :source, :sample_ratio, :sample_type, :rescaled, :sample_weight_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
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

    class << SessionRepresentation =
        Base.new(:query_id, :transaction_id, :client_transaction_support, :user, :principal, :source, :catalog, :schema, :time_zone_key, :locale, :remote_user_address, :user_agent, :start_time, :system_properties, :catalog_properties)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["queryId"],
          hash["transactionId"],
          hash["clientTransactionSupport"],
          hash["user"],
          hash["principal"],
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
        Base.new(:state, :can_add_buffers, :can_add_pages, :total_buffered_bytes, :total_buffered_pages, :total_queued_pages, :total_pages_sent, :buffers)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["state"] && hash["state"].downcase.to_sym,
          hash["canAddBuffers"],
          hash["canAddPages"],
          hash["totalBufferedBytes"],
          hash["totalBufferedPages"],
          hash["totalQueuedPages"],
          hash["totalPagesSent"],
          hash["buffers"] && hash["buffers"].map {|h| BufferInfo.decode(h) },
        )
        obj
      end
    end

    class << Signature =
        Base.new(:name, :kind, :type_parameter_requirements, :return_type, :argument_types, :variable_arity)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["name"],
          hash["kind"] && hash["kind"].downcase.to_sym,
          hash["typeParameterRequirements"] && hash["typeParameterRequirements"].map {|h| TypeParameterRequirement.decode(h) },
          hash["returnType"],
          hash["argumentTypes"],
          hash["variableArity"],
        )
        obj
      end
    end

    class << SortNode =
        Base.new(:id, :source, :order_by, :orderings)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["orderBy"],
          hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
        )
        obj
      end
    end

    class << StageInfo =
        Base.new(:stage_id, :state, :self, :plan, :types, :stage_stats, :tasks, :sub_stages, :failure_cause)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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
          hash["failureCause"] && ExecutionFailureInfo.decode(hash["failureCause"]),
        )
        obj
      end
    end

    class << StageStats =
        Base.new(:scheduling_complete, :get_split_distribution, :schedule_task_distribution, :add_split_distribution, :total_tasks, :running_tasks, :completed_tasks, :total_drivers, :queued_drivers, :running_drivers, :completed_drivers, :cumulative_memory, :total_memory_reservation, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["schedulingComplete"],
          hash["getSplitDistribution"] && DistributionSnapshot.decode(hash["getSplitDistribution"]),
          hash["scheduleTaskDistribution"] && DistributionSnapshot.decode(hash["scheduleTaskDistribution"]),
          hash["addSplitDistribution"] && DistributionSnapshot.decode(hash["addSplitDistribution"]),
          hash["totalTasks"],
          hash["runningTasks"],
          hash["completedTasks"],
          hash["totalDrivers"],
          hash["queuedDrivers"],
          hash["runningDrivers"],
          hash["completedDrivers"],
          hash["cumulativeMemory"],
          hash["totalMemoryReservation"],
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalUserTime"],
          hash["totalBlockedTime"],
          hash["fullyBlocked"],
          hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
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

    class << StatementStats =
        Base.new(:state, :scheduled, :nodes, :total_splits, :queued_splits, :running_splits, :completed_splits, :user_time_millis, :cpu_time_millis, :wall_time_millis, :processed_rows, :processed_bytes, :root_stage)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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
          hash["rootStage"] && ClientStageStats.decode(hash["rootStage"]),
        )
        obj
      end
    end

    class << TableFinishNode =
        Base.new(:id, :source, :target, :outputs)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << TableLayoutHandle =
        Base.new(:connector_id, :transaction_handle, :connector_handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["transactionHandle"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << TableScanNode =
        Base.new(:id, :table, :output_symbols, :assignments, :layout, :current_constraint, :original_constraint)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["table"] && TableHandle.decode(hash["table"]),
          hash["outputSymbols"],
          hash["assignments"],
          hash["layout"] && TableLayoutHandle.decode(hash["layout"]),
          hash["currentConstraint"],
          hash["originalConstraint"],
        )
        obj
      end
    end

    class << TableWriterNode =
        Base.new(:id, :source, :target, :columns, :column_names, :outputs, :sample_weight_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
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
        Base.new(:task_id, :task_instance_id, :version, :state, :self, :last_heartbeat, :output_buffers, :no_more_splits, :stats, :failures)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["taskId"] && TaskId.new(hash["taskId"]),
          hash["taskInstanceId"],
          hash["version"],
          hash["state"] && hash["state"].downcase.to_sym,
          hash["self"],
          hash["lastHeartbeat"],
          hash["outputBuffers"] && SharedBufferInfo.decode(hash["outputBuffers"]),
          hash["noMoreSplits"],
          hash["stats"] && TaskStats.decode(hash["stats"]),
          hash["failures"] && hash["failures"].map {|h| ExecutionFailureInfo.decode(h) },
        )
        obj
      end
    end

    class << TaskStats =
        Base.new(:create_time, :first_start_time, :last_start_time, :end_time, :elapsed_time, :queued_time, :total_drivers, :queued_drivers, :queued_partitioned_drivers, :running_drivers, :running_partitioned_drivers, :completed_drivers, :cumulative_memory, :memory_reservation, :system_memory_reservation, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :pipelines)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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
          hash["cumulativeMemory"],
          hash["memoryReservation"],
          hash["systemMemoryReservation"],
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalUserTime"],
          hash["totalBlockedTime"],
          hash["fullyBlocked"],
          hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
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
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["count"],
          hash["orderBy"],
          hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
          hash["partial"],
        )
        obj
      end
    end

    class << TopNRowNumberNode =
        Base.new(:id, :source, :partition_by, :order_by, :orderings, :row_number_symbol, :max_row_count_per_partition, :partial, :hash_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["partitionBy"],
          hash["orderBy"],
          hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
          hash["rowNumberSymbol"],
          hash["maxRowCountPerPartition"],
          hash["partial"],
          hash["hashSymbol"],
        )
        obj
      end
    end

    class << TypeParameterRequirement =
        Base.new(:name, :comparable_required, :orderable_required, :variadic_bound)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
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

    class << UnionNode =
        Base.new(:id, :sources, :symbol_mapping)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["sources"] && hash["sources"].map {|h| PlanNode.decode(h) },
          hash["symbolMapping"],
        )
        obj
      end
    end

    class << UnnestNode =
        Base.new(:id, :source, :replicate_symbols, :unnest_symbols, :ordinality_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["replicateSymbols"],
          hash["unnestSymbols"],
          hash["ordinalitySymbol"],
        )
        obj
      end
    end

    class << ValuesNode =
        Base.new(:id, :output_symbols, :rows)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["outputSymbols"],
          hash["rows"],
        )
        obj
      end
    end

    class << WindowNode =
        Base.new(:id, :source, :partition_by, :order_by, :orderings, :frame, :window_functions, :signatures, :hash_symbol, :pre_partitioned_inputs, :pre_sorted_order_prefix)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["partitionBy"],
          hash["orderBy"],
          hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
          hash["frame"],
          hash["windowFunctions"],
          hash["signatures"] && Hash[hash["signatures"].to_a.map! {|k,v| [k, Signature.decode(v)] }],
          hash["hashSymbol"],
          hash["prePartitionedInputs"],
          hash["preSortedOrderPrefix"],
        )
        obj
      end
    end


  end
end

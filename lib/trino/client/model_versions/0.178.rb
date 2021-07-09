#
# Trino client for Ruby
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
module Trino::Client::ModelVersions

  ####
  ## lib/trino/client/model_versions/*.rb is automatically generated using "rake modelgen:all" command.
  ## You should not edit this file directly. To modify the class definitions, edit
  ## modelgen/model_versions.rb file and run "rake modelgen:all".
  ##

  module V0_178
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
          when "intersect"          then IntersectNode
          when "scalar"             then EnforceSingleRowNode
          when "groupid"            then GroupIdNode
          when "explainAnalyze"     then ExplainAnalyzeNode
          when "apply"              then ApplyNode
          when "assignUniqueId"     then AssignUniqueId
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
            when "CreateHandle"       then CreateHandle
            when "InsertHandle"       then InsertHandle
            when "DeleteHandle"       then DeleteHandle
        end
        if model_class
           model_class.decode(hash)
        end
      end
    end

    # Inner classes 
    module OperatorInfo
      def self.decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        model_class = case hash["@type"]
          when "exchangeClientStatus"   then ExchangeClientStatus
          when "localExchangeBuffer"    then LocalExchangeBufferInfo
          when "tableFinish"            then TableFinishInfo
          when "splitOperator"          then SplitOperatorInfo
          when "hashCollisionsInfo"     then HashCollisionsInfo
          when "partitionedOutput"      then PartitionedOutputInfo
        end
        if model_class
           model_class.decode(hash)
        end
      end
    end

    class << HashCollisionsInfo =
        Base.new(:weighted_hash_collisions, :weighted_sum_squared_hash_collisions, :weighted_expectedHash_collisions)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["weighted_hash_collisions"],
          hash["weighted_sum_squared_hash_collisions"],
          hash["weighted_expectedHash_collisions"]
        )
        obj
      end
    end

    ##
    # Those model classes are automatically generated
    #

    class << Aggregation =
        Base.new(:call, :signature, :mask)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["call"],
          hash["signature"] && Signature.decode(hash["signature"]),
          hash["mask"],
        )
        obj
      end
    end

    class << AggregationNode =
        Base.new(:id, :source, :assignments, :grouping_sets, :step, :hash_symbol, :group_id_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["assignments"] && Hash[hash["assignments"].to_a.map! {|k,v| [k, Aggregation.decode(v)] }],
          hash["groupingSets"],
          hash["step"] && hash["step"].downcase.to_sym,
          hash["hashSymbol"],
          hash["groupIdSymbol"],
        )
        obj
      end
    end

    class << ApplyNode =
        Base.new(:id, :input, :subquery, :subquery_assignments, :correlation)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["input"] && PlanNode.decode(hash["input"]),
          hash["subquery"] && PlanNode.decode(hash["subquery"]),
          hash["subqueryAssignments"] && Assignments.decode(hash["subqueryAssignments"]),
          hash["correlation"],
        )
        obj
      end
    end

    class << ArgumentBinding =
        Base.new(:column, :constant)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["column"],
          hash["constant"],
        )
        obj
      end
    end

    class << AssignUniqueId =
        Base.new(:id, :source, :id_column)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["idColumn"],
        )
        obj
      end
    end

    class << Assignments =
        Base.new(:assignments)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["assignments"],
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
          hash["bufferId"],
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

    class << CreateHandle =
        Base.new(:handle, :schema_table_name)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["handle"] && OutputTableHandle.decode(hash["handle"]),
          hash["schemaTableName"] && SchemaTableName.decode(hash["schemaTableName"]),
        )
        obj
      end
    end

    class << DeleteHandle =
        Base.new(:handle, :schema_table_name)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["handle"] && TableHandle.decode(hash["handle"]),
          hash["schemaTableName"] && SchemaTableName.decode(hash["schemaTableName"]),
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
        Base.new(:id, :source, :limit, :partial, :distinct_symbols, :hash_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["limit"],
          hash["partial"],
          hash["distinctSymbols"],
          hash["hashSymbol"],
        )
        obj
      end
    end

    class << DriverStats =
        Base.new(:create_time, :start_time, :end_time, :queued_time, :elapsed_time, :memory_reservation, :peak_memory_reservation, :system_memory_reservation, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :raw_input_data_size, :raw_input_positions, :raw_input_read_time, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :operator_stats)
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
          hash["peakMemoryReservation"],
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
        Base.new(:code, :name, :type)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["code"],
          hash["name"],
          hash["type"] && hash["type"].downcase.to_sym,
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

    class << ExchangeClientStatus =
        Base.new(:buffered_bytes, :max_buffered_bytes, :average_bytes_per_request, :successful_requests_count, :buffered_pages, :no_more_locations, :page_buffer_client_statuses)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["bufferedBytes"],
          hash["maxBufferedBytes"],
          hash["averageBytesPerRequest"],
          hash["successfulRequestsCount"],
          hash["bufferedPages"],
          hash["noMoreLocations"],
          hash["pageBufferClientStatuses"] && hash["pageBufferClientStatuses"].map {|h| PageBufferClientStatus.decode(h) },
        )
        obj
      end
    end

    class << ExchangeNode =
        Base.new(:id, :type, :scope, :partitioning_scheme, :sources, :inputs)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["type"],
          hash["scope"] && hash["scope"].downcase.to_sym,
          hash["partitioningScheme"] && PartitioningScheme.decode(hash["partitioningScheme"]),
          hash["sources"] && hash["sources"].map {|h| PlanNode.decode(h) },
          hash["inputs"],
        )
        obj
      end
    end

    class << ExecutionFailureInfo =
        Base.new(:type, :message, :cause, :suppressed, :stack, :error_location, :error_code, :remote_host)
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
          hash["remoteHost"],
        )
        obj
      end
    end

    class << ExplainAnalyzeNode =
        Base.new(:id, :source, :output_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["outputSymbol"],
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

    class << Function =
        Base.new(:function_call, :signature, :frame)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["functionCall"],
          hash["signature"] && Signature.decode(hash["signature"]),
          hash["frame"],
        )
        obj
      end
    end

    class << GroupIdNode =
        Base.new(:id, :source, :grouping_sets, :grouping_set_mappings, :argument_mappings, :group_id_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["groupingSets"],
          hash["groupingSetMappings"],
          hash["argumentMappings"],
          hash["groupIdSymbol"],
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
        Base.new(:id, :index_handle, :table_handle, :table_layout, :lookup_symbols, :output_symbols, :assignments, :effective_tuple_domain)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["indexHandle"] && IndexHandle.decode(hash["indexHandle"]),
          hash["tableHandle"] && TableHandle.decode(hash["tableHandle"]),
          hash["tableLayout"] && TableLayoutHandle.decode(hash["tableLayout"]),
          hash["lookupSymbols"],
          hash["outputSymbols"],
          hash["assignments"],
          hash["effectiveTupleDomain"],
        )
        obj
      end
    end

    class << Input =
        Base.new(:connector_id, :schema, :table, :connector_info, :columns)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["schema"],
          hash["table"],
          hash["connectorInfo"],
          hash["columns"] && hash["columns"].map {|h| Column.decode(h) },
        )
        obj
      end
    end

    class << InsertHandle =
        Base.new(:handle, :schema_table_name)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["handle"] && InsertTableHandle.decode(hash["handle"]),
          hash["schemaTableName"] && SchemaTableName.decode(hash["schemaTableName"]),
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

    class << IntersectNode =
        Base.new(:id, :sources, :output_to_inputs, :outputs)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["sources"] && hash["sources"].map {|h| PlanNode.decode(h) },
          hash["outputToInputs"],
          hash["outputs"],
        )
        obj
      end
    end

    class << JoinNode =
        Base.new(:id, :type, :left, :right, :criteria, :output_symbols, :filter, :left_hash_symbol, :right_hash_symbol, :distribution_type)
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
          hash["outputSymbols"],
          hash["filter"],
          hash["leftHashSymbol"],
          hash["rightHashSymbol"],
          hash["distributionType"] && hash["distributionType"].downcase.to_sym,
        )
        obj
      end
    end

    class << LimitNode =
        Base.new(:id, :source, :count, :partial)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["count"],
          hash["partial"],
        )
        obj
      end
    end

    class << LocalExchangeBufferInfo =
        Base.new(:buffered_bytes, :buffered_pages)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["bufferedBytes"],
          hash["bufferedPages"],
        )
        obj
      end
    end

    class << LongVariableConstraint =
        Base.new(:name, :expression)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["name"],
          hash["expression"],
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
        Base.new(:pipeline_id, :operator_id, :plan_node_id, :operator_type, :total_drivers, :add_input_calls, :add_input_wall, :add_input_cpu, :add_input_user, :input_data_size, :input_positions, :sum_squared_input_positions, :get_output_calls, :get_output_wall, :get_output_cpu, :get_output_user, :output_data_size, :output_positions, :blocked_wall, :finish_calls, :finish_wall, :finish_cpu, :finish_user, :memory_reservation, :system_memory_reservation, :blocked_reason, :info)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["pipelineId"],
          hash["operatorId"],
          hash["planNodeId"],
          hash["operatorType"],
          hash["totalDrivers"],
          hash["addInputCalls"],
          hash["addInputWall"],
          hash["addInputCpu"],
          hash["addInputUser"],
          hash["inputDataSize"],
          hash["inputPositions"],
          hash["sumSquaredInputPositions"],
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
          hash["blockedReason"] && hash["blockedReason"].downcase.to_sym,
          hash["info"] && OperatorInfo.decode(hash["info"]),
        )
        obj
      end
    end

    class << Output =
        Base.new(:connector_id, :schema, :table)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorId"],
          hash["schema"],
          hash["table"],
        )
        obj
      end
    end

    class << OutputBufferInfo =
        Base.new(:type, :state, :can_add_buffers, :can_add_pages, :total_buffered_bytes, :total_buffered_pages, :total_rows_sent, :total_pages_sent, :buffers)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["type"],
          hash["state"] && hash["state"].downcase.to_sym,
          hash["canAddBuffers"],
          hash["canAddPages"],
          hash["totalBufferedBytes"],
          hash["totalBufferedPages"],
          hash["totalRowsSent"],
          hash["totalPagesSent"],
          hash["buffers"] && hash["buffers"].map {|h| BufferInfo.decode(h) },
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

    class << PageBufferClientStatus =
        Base.new(:uri, :state, :last_update, :rows_received, :pages_received, :rows_rejected, :pages_rejected, :requests_scheduled, :requests_completed, :requests_failed, :http_request_state)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["uri"],
          hash["state"],
          hash["lastUpdate"],
          hash["rowsReceived"],
          hash["pagesReceived"],
          hash["rowsRejected"],
          hash["pagesRejected"],
          hash["requestsScheduled"],
          hash["requestsCompleted"],
          hash["requestsFailed"],
          hash["httpRequestState"],
        )
        obj
      end
    end

    class << PageBufferInfo =
        Base.new(:partition, :buffered_pages, :buffered_bytes, :rows_added, :pages_added)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["partition"],
          hash["bufferedPages"],
          hash["bufferedBytes"],
          hash["rowsAdded"],
          hash["pagesAdded"],
        )
        obj
      end
    end

    class << Partitioning =
        Base.new(:handle, :arguments)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["handle"] && PartitioningHandle.decode(hash["handle"]),
          hash["arguments"] && hash["arguments"].map {|h| ArgumentBinding.decode(h) },
        )
        obj
      end
    end

    class << PartitioningHandle =
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

    class << PartitioningScheme =
        Base.new(:partitioning, :output_layout, :hash_column, :replicate_nulls_and_any, :bucket_to_partition)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["partitioning"] && Partitioning.decode(hash["partitioning"]),
          hash["outputLayout"],
          hash["hashColumn"],
          hash["replicateNullsAndAny"],
          hash["bucketToPartition"],
        )
        obj
      end
    end

    class << PipelineStats =
        Base.new(:pipeline_id, :first_start_time, :last_start_time, :last_end_time, :input_pipeline, :output_pipeline, :total_drivers, :queued_drivers, :queued_partitioned_drivers, :running_drivers, :running_partitioned_drivers, :blocked_drivers, :completed_drivers, :memory_reservation, :system_memory_reservation, :queued_time, :elapsed_time, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :operator_summaries, :drivers)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["pipelineId"],
          hash["firstStartTime"],
          hash["lastStartTime"],
          hash["lastEndTime"],
          hash["inputPipeline"],
          hash["outputPipeline"],
          hash["totalDrivers"],
          hash["queuedDrivers"],
          hash["queuedPartitionedDrivers"],
          hash["runningDrivers"],
          hash["runningPartitionedDrivers"],
          hash["blockedDrivers"],
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
        Base.new(:id, :root, :symbols, :partitioning, :partitioned_sources, :partitioning_scheme)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["root"] && PlanNode.decode(hash["root"]),
          hash["symbols"],
          hash["partitioning"] && PartitioningHandle.decode(hash["partitioning"]),
          hash["partitionedSources"],
          hash["partitioningScheme"] && PartitioningScheme.decode(hash["partitioningScheme"]),
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
          hash["assignments"] && Assignments.decode(hash["assignments"]),
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
        Base.new(:query_id, :session, :state, :memory_pool, :scheduled, :self, :field_names, :query, :query_stats, :set_session_properties, :reset_session_properties, :added_prepared_statements, :deallocated_prepared_statements, :started_transaction_id, :clear_transaction_id, :update_type, :output_stage, :failure_info, :error_code, :inputs, :output, :complete_info, :resource_group_name, :final_query_info)
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
          hash["addedPreparedStatements"],
          hash["deallocatedPreparedStatements"],
          hash["startedTransactionId"],
          hash["clearTransactionId"],
          hash["updateType"],
          hash["outputStage"] && StageInfo.decode(hash["outputStage"]),
          hash["failureInfo"] && FailureInfo.decode(hash["failureInfo"]),
          hash["errorCode"] && ErrorCode.decode(hash["errorCode"]),
          hash["inputs"] && hash["inputs"].map {|h| Input.decode(h) },
          hash["output"] && Output.decode(hash["output"]),
          hash["completeInfo"],
          hash["resourceGroupName"],
          hash["finalQueryInfo"],
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
        Base.new(:create_time, :execution_start_time, :last_heartbeat, :end_time, :elapsed_time, :queued_time, :analysis_time, :distributed_planning_time, :total_planning_time, :finishing_time, :total_tasks, :running_tasks, :completed_tasks, :total_drivers, :queued_drivers, :running_drivers, :blocked_drivers, :completed_drivers, :cumulative_memory, :total_memory_reservation, :peak_memory_reservation, :scheduled, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :operator_summaries)
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
          hash["blockedDrivers"],
          hash["completedDrivers"],
          hash["cumulativeMemory"],
          hash["totalMemoryReservation"],
          hash["peakMemoryReservation"],
          hash["scheduled"],
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
        Base.new(:id, :source, :sample_ratio, :sample_type)
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
        )
        obj
      end
    end

    class << SchemaTableName =
        Base.new(:schema, :table)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["schema"],
          hash["table"],
        )
        obj
      end
    end

    class << SemiJoinNode =
        Base.new(:id, :source, :filtering_source, :source_join_symbol, :filtering_source_join_symbol, :semi_join_output, :source_hash_symbol, :filtering_source_hash_symbol, :distribution_type)
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
          hash["distributionType"] && hash["distributionType"].downcase.to_sym,
        )
        obj
      end
    end

    class << SessionRepresentation =
        Base.new(:query_id, :transaction_id, :client_transaction_support, :user, :principal, :source, :catalog, :schema, :time_zone_key, :locale, :remote_user_address, :user_agent, :client_info, :start_time, :system_properties, :catalog_properties, :prepared_statements)
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
          hash["clientInfo"],
          hash["startTime"],
          hash["systemProperties"],
          hash["catalogProperties"],
          hash["preparedStatements"],
        )
        obj
      end
    end

    class << Signature =
        Base.new(:name, :kind, :type_variable_constraints, :long_variable_constraints, :return_type, :argument_types, :variable_arity)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["name"],
          hash["kind"] && hash["kind"].downcase.to_sym,
          hash["typeVariableConstraints"] && hash["typeVariableConstraints"].map {|h| TypeVariableConstraint.decode(h) },
          hash["longVariableConstraints"] && hash["longVariableConstraints"].map {|h| LongVariableConstraint.decode(h) },
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

    class << Specification =
        Base.new(:partition_by, :order_by, :orderings)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["partitionBy"],
          hash["orderBy"],
          hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
        )
        obj
      end
    end

    class << SplitOperatorInfo =
        Base.new(:split_info)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["splitInfo"],
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
        Base.new(:scheduling_complete, :get_split_distribution, :schedule_task_distribution, :add_split_distribution, :total_tasks, :running_tasks, :completed_tasks, :total_drivers, :queued_drivers, :running_drivers, :blocked_drivers, :completed_drivers, :cumulative_memory, :total_memory_reservation, :peak_memory_reservation, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :buffered_data_size, :output_data_size, :output_positions, :operator_summaries)
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
          hash["blockedDrivers"],
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
          hash["bufferedDataSize"],
          hash["outputDataSize"],
          hash["outputPositions"],
          hash["operatorSummaries"] && hash["operatorSummaries"].map {|h| OperatorStats.decode(h) },
        )
        obj
      end
    end

    class << StatementStats =
        Base.new(:state, :queued, :scheduled, :nodes, :total_splits, :queued_splits, :running_splits, :completed_splits, :user_time_millis, :cpu_time_millis, :wall_time_millis, :processed_rows, :processed_bytes, :root_stage)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["state"],
          hash["queued"],
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

    class << TableFinishInfo =
        Base.new(:connector_output_metadata)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorOutputMetadata"],
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
        Base.new(:id, :source, :target, :columns, :column_names, :outputs, :partitioning_scheme)
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
          hash["partitioningScheme"] && PartitioningScheme.decode(hash["partitioningScheme"]),
        )
        obj
      end
    end

    class << TaskInfo =
        Base.new(:task_status, :last_heartbeat, :output_buffers, :no_more_splits, :stats, :needs_plan, :complete)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["taskStatus"] && TaskStatus.decode(hash["taskStatus"]),
          hash["lastHeartbeat"],
          hash["outputBuffers"] && OutputBufferInfo.decode(hash["outputBuffers"]),
          hash["noMoreSplits"],
          hash["stats"] && TaskStats.decode(hash["stats"]),
          hash["needsPlan"],
          hash["complete"],
        )
        obj
      end
    end

    class << TaskStats =
        Base.new(:create_time, :first_start_time, :last_start_time, :last_end_time, :end_time, :elapsed_time, :queued_time, :total_drivers, :queued_drivers, :queued_partitioned_drivers, :running_drivers, :running_partitioned_drivers, :blocked_drivers, :completed_drivers, :cumulative_memory, :memory_reservation, :system_memory_reservation, :total_scheduled_time, :total_cpu_time, :total_user_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :pipelines)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["createTime"],
          hash["firstStartTime"],
          hash["lastStartTime"],
          hash["lastEndTime"],
          hash["endTime"],
          hash["elapsedTime"],
          hash["queuedTime"],
          hash["totalDrivers"],
          hash["queuedDrivers"],
          hash["queuedPartitionedDrivers"],
          hash["runningDrivers"],
          hash["runningPartitionedDrivers"],
          hash["blockedDrivers"],
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

    class << TaskStatus =
        Base.new(:task_id, :task_instance_id, :version, :state, :self, :failures, :queued_partitioned_drivers, :running_partitioned_drivers, :memory_reservation)
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
          hash["failures"] && hash["failures"].map {|h| ExecutionFailureInfo.decode(h) },
          hash["queuedPartitionedDrivers"],
          hash["runningPartitionedDrivers"],
          hash["memoryReservation"],
        )
        obj
      end
    end

    class << TopNNode =
        Base.new(:id, :source, :count, :order_by, :orderings, :step)
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
          hash["step"] && hash["step"].downcase.to_sym,
        )
        obj
      end
    end

    class << TopNRowNumberNode =
        Base.new(:id, :source, :specification, :row_number_symbol, :max_row_count_per_partition, :partial, :hash_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["specification"] && Specification.decode(hash["specification"]),
          hash["rowNumberSymbol"],
          hash["maxRowCountPerPartition"],
          hash["partial"],
          hash["hashSymbol"],
        )
        obj
      end
    end

    class << TypeVariableConstraint =
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
        Base.new(:id, :sources, :output_to_inputs, :outputs)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["sources"] && hash["sources"].map {|h| PlanNode.decode(h) },
          hash["outputToInputs"],
          hash["outputs"],
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
        Base.new(:id, :source, :specification, :window_functions, :hash_symbol, :pre_partitioned_inputs, :pre_sorted_order_prefix)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["specification"] && Specification.decode(hash["specification"]),
          hash["windowFunctions"] && Hash[hash["windowFunctions"].to_a.map! {|k,v| [k, Function.decode(v)] }],
          hash["hashSymbol"],
          hash["prePartitionedInputs"],
          hash["preSortedOrderPrefix"],
        )
        obj
      end
    end


  end
end

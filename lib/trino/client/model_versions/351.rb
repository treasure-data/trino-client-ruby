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

  module V351
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

    class Lifespan < String
      def initialize(str)
        super
        if str == "TaskWide"
          @grouped = false
          @group_id = 0
        else
          # Group1
          @grouped = true
          @group_id = str[5..-1].to_i
        end
      end

      attr_reader :grouped, :group_id
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
          when "spatialjoin"        then SpatialJoinNode
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
          when "correlatedJoin"     then CorrelatedJoinNode
          when "statisticsWriterNode" then StatisticsWriterNode
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
            when "CreateTarget"       then CreateTarget
            when "InsertTarget"       then InsertTarget
            when "DeleteTarget"       then DeleteTarget
        end
        if model_class
           model_class.decode(hash)
        end
      end
    end

    class << WriteStatisticsTarget =
        Base.new(:type, :handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        model_class = case hash["@type"]
            when "WriteStatisticsHandle"       then WriteStatisticsHandle
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
          when "joinOperatorInfo"       then JoinOperatorInfo
          when "windowInfo"             then WindowInfo
          when "tableWriter"            then TableWriterInfo
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

    class ResourceGroupId < Array
      def initialize(array)
        super()
        concat(array)
      end
    end

    ##
    # Those model classes are automatically generated
    #

    class << Aggregation =
        Base.new(:resolved_function, :arguments, :distinct, :filter, :ordering_scheme, :mask)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["resolvedFunction"] && ResolvedFunction.decode(hash["resolvedFunction"]),
          hash["arguments"],
          hash["distinct"],
          hash["filter"],
          hash["orderingScheme"] && OrderingScheme.decode(hash["orderingScheme"]),
          hash["mask"],
        )
        obj
      end
    end

    class << AggregationNode =
        Base.new(:id, :source, :aggregations, :grouping_sets, :pre_grouped_symbols, :step, :hash_symbol, :group_id_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["aggregations"] && Hash[hash["aggregations"].to_a.map! {|k,v| [k, Aggregation.decode(v)] }],
          hash["groupingSets"] && GroupingSetDescriptor.decode(hash["groupingSets"]),
          hash["preGroupedSymbols"],
          hash["step"] && hash["step"].downcase.to_sym,
          hash["hashSymbol"],
          hash["groupIdSymbol"],
        )
        obj
      end
    end

    class << AnalyzeTableHandle =
        Base.new(:catalog_name, :transaction_handle, :connector_handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["catalogName"],
          hash["transactionHandle"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << ApplyNode =
        Base.new(:id, :input, :subquery, :subquery_assignments, :correlation, :origin_subquery)
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
          hash["originSubquery"],
        )
        obj
      end
    end

    class << ArgumentBinding =
        Base.new(:expression, :constant)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["expression"],
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

    class << BasicQueryInfo =
        Base.new(:query_id, :session, :resource_group_id, :state, :memory_pool, :scheduled, :self, :query, :update_type, :prepared_query, :query_stats, :error_type, :error_code, :query_type)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["queryId"],
          hash["session"] && SessionRepresentation.decode(hash["session"]),
          hash["resourceGroupId"] && ResourceGroupId.new(hash["resourceGroupId"]),
          hash["state"] && hash["state"].downcase.to_sym,
          hash["memoryPool"],
          hash["scheduled"],
          hash["self"],
          hash["query"],
          hash["updateType"],
          hash["preparedQuery"],
          hash["queryStats"] && BasicQueryStats.decode(hash["queryStats"]),
          hash["errorType"] && hash["errorType"].downcase.to_sym,
          hash["errorCode"] && ErrorCode.decode(hash["errorCode"]),
          hash["queryType"] && hash["queryType"].downcase.to_sym,
        )
        obj
      end
    end

    class << BasicQueryStats =
        Base.new(:create_time, :end_time, :queued_time, :elapsed_time, :execution_time, :total_drivers, :queued_drivers, :running_drivers, :completed_drivers, :raw_input_data_size, :raw_input_positions, :physical_input_data_size, :cumulative_user_memory, :user_memory_reservation, :total_memory_reservation, :peak_user_memory_reservation, :peak_total_memory_reservation, :total_cpu_time, :total_scheduled_time, :fully_blocked, :blocked_reasons, :progress_percentage)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["createTime"],
          hash["endTime"],
          hash["queuedTime"],
          hash["elapsedTime"],
          hash["executionTime"],
          hash["totalDrivers"],
          hash["queuedDrivers"],
          hash["runningDrivers"],
          hash["completedDrivers"],
          hash["rawInputDataSize"],
          hash["rawInputPositions"],
          hash["physicalInputDataSize"],
          hash["cumulativeUserMemory"],
          hash["userMemoryReservation"],
          hash["totalMemoryReservation"],
          hash["peakUserMemoryReservation"],
          hash["peakTotalMemoryReservation"],
          hash["totalCpuTime"],
          hash["totalScheduledTime"],
          hash["fullyBlocked"],
          hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
          hash["progressPercentage"],
        )
        obj
      end
    end

    class << BoundSignature =
        Base.new(:name, :return_type, :argument_types)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["name"],
          hash["returnType"],
          hash["argumentTypes"],
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
        Base.new(:stage_id, :state, :done, :nodes, :total_splits, :queued_splits, :running_splits, :completed_splits, :cpu_time_millis, :wall_time_millis, :processed_rows, :processed_bytes, :physical_input_bytes, :sub_stages)
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
          hash["cpuTimeMillis"],
          hash["wallTimeMillis"],
          hash["processedRows"],
          hash["processedBytes"],
          hash["physicalInputBytes"],
          hash["subStages"] && hash["subStages"].map {|h| ClientStageStats.decode(h) },
        )
        obj
      end
    end

    class << ClientTypeSignature =
        Base.new(:raw_type, :arguments)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["rawType"],
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

    class << Code =
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

    class << ColumnStatisticMetadata =
        Base.new(:column_name, :statistic_type)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["columnName"],
          hash["statisticType"] && hash["statisticType"].downcase.to_sym,
        )
        obj
      end
    end

    class << CorrelatedJoinNode =
        Base.new(:id, :input, :subquery, :correlation, :type, :filter, :origin_subquery)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["input"] && PlanNode.decode(hash["input"]),
          hash["subquery"] && PlanNode.decode(hash["subquery"]),
          hash["correlation"],
          hash["type"],
          hash["filter"],
          hash["originSubquery"],
        )
        obj
      end
    end

    class << CreateTarget =
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
          hash["target"] && DeleteTarget.decode(hash["target"]),
          hash["rowId"],
          hash["outputs"],
        )
        obj
      end
    end

    class << DeleteTarget =
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
        Base.new(:lifespan, :create_time, :start_time, :end_time, :queued_time, :elapsed_time, :user_memory_reservation, :revocable_memory_reservation, :system_memory_reservation, :total_scheduled_time, :total_cpu_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :physical_input_data_size, :physical_input_positions, :physical_input_read_time, :internal_network_input_data_size, :internal_network_input_positions, :internal_network_input_read_time, :raw_input_data_size, :raw_input_positions, :raw_input_read_time, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :physical_written_data_size, :operator_stats)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["lifespan"] && Lifespan.new(hash["lifespan"]),
          hash["createTime"],
          hash["startTime"],
          hash["endTime"],
          hash["queuedTime"],
          hash["elapsedTime"],
          hash["userMemoryReservation"],
          hash["revocableMemoryReservation"],
          hash["systemMemoryReservation"],
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalBlockedTime"],
          hash["fullyBlocked"],
          hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
          hash["physicalInputDataSize"],
          hash["physicalInputPositions"],
          hash["physicalInputReadTime"],
          hash["internalNetworkInputDataSize"],
          hash["internalNetworkInputPositions"],
          hash["internalNetworkInputReadTime"],
          hash["rawInputDataSize"],
          hash["rawInputPositions"],
          hash["rawInputReadTime"],
          hash["processedInputDataSize"],
          hash["processedInputPositions"],
          hash["outputDataSize"],
          hash["outputPositions"],
          hash["physicalWrittenDataSize"],
          hash["operatorStats"] && hash["operatorStats"].map {|h| OperatorStats.decode(h) },
        )
        obj
      end
    end

    class << DriverWindowInfo =
        Base.new(:sum_squared_differences_positions_of_index, :sum_squared_differences_size_of_index, :sum_squared_differences_size_in_partition, :total_partitions_count, :total_rows_count, :number_of_indexes)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["sumSquaredDifferencesPositionsOfIndex"],
          hash["sumSquaredDifferencesSizeOfIndex"],
          hash["sumSquaredDifferencesSizeInPartition"],
          hash["totalPartitionsCount"],
          hash["totalRowsCount"],
          hash["numberOfIndexes"],
        )
        obj
      end
    end

    class << DynamicFilterDomainStats =
        Base.new(:dynamic_filter_id, :simplified_domain, :range_count, :discrete_values_count, :collection_duration)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["dynamicFilterId"],
          hash["simplifiedDomain"],
          hash["rangeCount"],
          hash["discreteValuesCount"],
          hash["collectionDuration"],
        )
        obj
      end
    end

    class << DynamicFiltersStats =
        Base.new(:dynamic_filter_domain_stats, :lazy_dynamic_filters, :replicated_dynamic_filters, :total_dynamic_filters, :dynamic_filters_completed)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["dynamicFilterDomainStats"] && hash["dynamicFilterDomainStats"].map {|h| DynamicFilterDomainStats.decode(h) },
          hash["lazyDynamicFilters"],
          hash["replicatedDynamicFilters"],
          hash["totalDynamicFilters"],
          hash["dynamicFiltersCompleted"],
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
        Base.new(:id, :type, :scope, :partitioning_scheme, :sources, :inputs, :ordering_scheme)
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
          hash["orderingScheme"] && OrderingScheme.decode(hash["orderingScheme"]),
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
        Base.new(:id, :source, :output_symbol, :actual_outputs, :verbose)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["outputSymbol"],
          hash["actualOutputs"],
          hash["verbose"],
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
        Base.new(:resolved_function, :arguments, :frame, :ignore_nulls)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["resolvedFunction"] && ResolvedFunction.decode(hash["resolvedFunction"]),
          hash["arguments"],
          hash["frame"],
          hash["ignoreNulls"],
        )
        obj
      end
    end

    class << GroupIdNode =
        Base.new(:id, :source, :grouping_sets, :grouping_columns, :aggregation_arguments, :group_id_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["groupingSets"],
          hash["groupingColumns"],
          hash["aggregationArguments"],
          hash["groupIdSymbol"],
        )
        obj
      end
    end

    class << GroupingSetDescriptor =
        Base.new(:grouping_keys, :grouping_set_count, :global_grouping_sets)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["groupingKeys"],
          hash["groupingSetCount"],
          hash["globalGroupingSets"],
        )
        obj
      end
    end

    class << IndexHandle =
        Base.new(:catalog_name, :transaction_handle, :connector_handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["catalogName"],
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
        Base.new(:id, :index_handle, :table_handle, :lookup_symbols, :output_symbols, :assignments)
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
        )
        obj
      end
    end

    class << Input =
        Base.new(:catalog_name, :schema, :table, :connector_info, :columns, :fragment_id, :plan_node_id)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["catalogName"],
          hash["schema"],
          hash["table"],
          hash["connectorInfo"],
          hash["columns"] && hash["columns"].map {|h| Column.decode(h) },
          hash["fragmentId"],
          hash["planNodeId"],
        )
        obj
      end
    end

    class << InsertTableHandle =
        Base.new(:catalog_name, :transaction_handle, :connector_handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["catalogName"],
          hash["transactionHandle"],
          hash["connectorHandle"],
        )
        obj
      end
    end

    class << InsertTarget =
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

    class << IntersectNode =
        Base.new(:id, :sources, :output_to_inputs, :outputs, :distinct)
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
          hash["distinct"],
        )
        obj
      end
    end

    class << JoinNode =
        Base.new(:id, :type, :left, :right, :criteria, :left_output_symbols, :right_output_symbols, :filter, :left_hash_symbol, :right_hash_symbol, :distribution_type, :spillable, :dynamic_filters, :reorder_join_stats_and_cost)
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
          hash["leftOutputSymbols"],
          hash["rightOutputSymbols"],
          hash["filter"],
          hash["leftHashSymbol"],
          hash["rightHashSymbol"],
          hash["distributionType"] && hash["distributionType"].downcase.to_sym,
          hash["spillable"],
          hash["dynamicFilters"],
          hash["reorderJoinStatsAndCost"] && PlanNodeStatsAndCostSummary.decode(hash["reorderJoinStatsAndCost"]),
        )
        obj
      end
    end

    class << JoinOperatorInfo =
        Base.new(:join_type, :log_histogram_probes, :log_histogram_output, :lookup_source_positions)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["joinType"] && hash["joinType"].downcase.to_sym,
          hash["logHistogramProbes"],
          hash["logHistogramOutput"],
          hash["lookupSourcePositions"],
        )
        obj
      end
    end

    class << LimitNode =
        Base.new(:id, :source, :count, :ties_resolving_scheme, :partial)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["count"],
          hash["tiesResolvingScheme"] && OrderingScheme.decode(hash["tiesResolvingScheme"]),
          hash["partial"],
        )
        obj
      end
    end

    class << LocalCostEstimate =
        Base.new(:cpu_cost, :max_memory, :network_cost)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["cpuCost"],
          hash["maxMemory"],
          hash["networkCost"],
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

    class << Mapping =
        Base.new(:input, :outputs)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["input"],
          hash["outputs"],
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

    class << OperatorStats =
        Base.new(:stage_id, :pipeline_id, :operator_id, :plan_node_id, :operator_type, :total_drivers, :add_input_calls, :add_input_wall, :add_input_cpu, :physical_input_data_size, :physical_input_positions, :internal_network_input_data_size, :internal_network_input_positions, :raw_input_data_size, :input_data_size, :input_positions, :sum_squared_input_positions, :get_output_calls, :get_output_wall, :get_output_cpu, :output_data_size, :output_positions, :dynamic_filter_splits_processed, :physical_written_data_size, :blocked_wall, :finish_calls, :finish_wall, :finish_cpu, :user_memory_reservation, :revocable_memory_reservation, :system_memory_reservation, :peak_user_memory_reservation, :peak_system_memory_reservation, :peak_revocable_memory_reservation, :peak_total_memory_reservation, :spilled_data_size, :blocked_reason, :info)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["stageId"],
          hash["pipelineId"],
          hash["operatorId"],
          hash["planNodeId"],
          hash["operatorType"],
          hash["totalDrivers"],
          hash["addInputCalls"],
          hash["addInputWall"],
          hash["addInputCpu"],
          hash["physicalInputDataSize"],
          hash["physicalInputPositions"],
          hash["internalNetworkInputDataSize"],
          hash["internalNetworkInputPositions"],
          hash["rawInputDataSize"],
          hash["inputDataSize"],
          hash["inputPositions"],
          hash["sumSquaredInputPositions"],
          hash["getOutputCalls"],
          hash["getOutputWall"],
          hash["getOutputCpu"],
          hash["outputDataSize"],
          hash["outputPositions"],
          hash["dynamicFilterSplitsProcessed"],
          hash["physicalWrittenDataSize"],
          hash["blockedWall"],
          hash["finishCalls"],
          hash["finishWall"],
          hash["finishCpu"],
          hash["userMemoryReservation"],
          hash["revocableMemoryReservation"],
          hash["systemMemoryReservation"],
          hash["peakUserMemoryReservation"],
          hash["peakSystemMemoryReservation"],
          hash["peakRevocableMemoryReservation"],
          hash["peakTotalMemoryReservation"],
          hash["spilledDataSize"],
          hash["blockedReason"] && hash["blockedReason"].downcase.to_sym,
          hash["info"] && OperatorInfo.decode(hash["info"]),
        )
        obj
      end
    end

    class << OrderingScheme =
        Base.new(:order_by, :orderings)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["orderBy"],
          hash["orderings"] && Hash[hash["orderings"].to_a.map! {|k,v| [k, v.downcase.to_sym] }],
        )
        obj
      end
    end

    class << Output =
        Base.new(:catalog_name, :schema, :table)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["catalogName"],
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
        Base.new(:catalog_name, :transaction_handle, :connector_handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["catalogName"],
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

    class << PartitionedOutputInfo =
        Base.new(:rows_added, :pages_added, :output_buffer_peak_memory_usage)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["rowsAdded"],
          hash["pagesAdded"],
          hash["outputBufferPeakMemoryUsage"],
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
        Base.new(:pipeline_id, :first_start_time, :last_start_time, :last_end_time, :input_pipeline, :output_pipeline, :total_drivers, :queued_drivers, :queued_partitioned_drivers, :running_drivers, :running_partitioned_drivers, :blocked_drivers, :completed_drivers, :user_memory_reservation, :revocable_memory_reservation, :system_memory_reservation, :queued_time, :elapsed_time, :total_scheduled_time, :total_cpu_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :physical_input_data_size, :physical_input_positions, :physical_input_read_time, :internal_network_input_data_size, :internal_network_input_positions, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :physical_written_data_size, :operator_summaries, :drivers)
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
          hash["userMemoryReservation"],
          hash["revocableMemoryReservation"],
          hash["systemMemoryReservation"],
          hash["queuedTime"] && DistributionSnapshot.decode(hash["queuedTime"]),
          hash["elapsedTime"] && DistributionSnapshot.decode(hash["elapsedTime"]),
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalBlockedTime"],
          hash["fullyBlocked"],
          hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
          hash["physicalInputDataSize"],
          hash["physicalInputPositions"],
          hash["physicalInputReadTime"],
          hash["internalNetworkInputDataSize"],
          hash["internalNetworkInputPositions"],
          hash["rawInputDataSize"],
          hash["rawInputPositions"],
          hash["processedInputDataSize"],
          hash["processedInputPositions"],
          hash["outputDataSize"],
          hash["outputPositions"],
          hash["physicalWrittenDataSize"],
          hash["operatorSummaries"] && hash["operatorSummaries"].map {|h| OperatorStats.decode(h) },
          hash["drivers"] && hash["drivers"].map {|h| DriverStats.decode(h) },
        )
        obj
      end
    end

    class << PlanCostEstimate =
        Base.new(:cpu_cost, :max_memory, :max_memory_when_outputting, :network_cost, :root_node_local_cost_estimate)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["cpuCost"],
          hash["maxMemory"],
          hash["maxMemoryWhenOutputting"],
          hash["networkCost"],
          hash["rootNodeLocalCostEstimate"] && LocalCostEstimate.decode(hash["rootNodeLocalCostEstimate"]),
        )
        obj
      end
    end

    class << PlanFragment =
        Base.new(:id, :root, :symbols, :partitioning, :partitioned_sources, :partitioning_scheme, :stage_execution_descriptor, :stats_and_costs, :json_representation)
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
          hash["stageExecutionDescriptor"] && StageExecutionDescriptor.decode(hash["stageExecutionDescriptor"]),
          hash["statsAndCosts"] && StatsAndCosts.decode(hash["statsAndCosts"]),
          hash["jsonRepresentation"],
        )
        obj
      end
    end

    class << PlanNodeStatsAndCostSummary =
        Base.new(:output_row_count, :output_size_in_bytes, :cpu_cost, :memory_cost, :network_cost)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["outputRowCount"],
          hash["outputSizeInBytes"],
          hash["cpuCost"],
          hash["memoryCost"],
          hash["networkCost"],
        )
        obj
      end
    end

    class << PlanNodeStatsEstimate =
        Base.new(:output_row_count, :symbol_statistics)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["outputRowCount"],
          hash["symbolStatistics"] && Hash[hash["symbolStatistics"].to_a.map! {|k,v| [k, SymbolStatsEstimate.decode(v)] }],
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
        Base.new(:query_id, :session, :state, :memory_pool, :scheduled, :self, :field_names, :query, :prepared_query, :query_stats, :set_catalog, :set_schema, :set_path, :set_session_properties, :reset_session_properties, :set_roles, :added_prepared_statements, :deallocated_prepared_statements, :started_transaction_id, :clear_transaction_id, :update_type, :output_stage, :failure_info, :error_code, :warnings, :inputs, :output, :referenced_tables, :routines, :complete_info, :resource_group_id, :query_type, :final_query_info)
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
          hash["preparedQuery"],
          hash["queryStats"] && QueryStats.decode(hash["queryStats"]),
          hash["setCatalog"],
          hash["setSchema"],
          hash["setPath"],
          hash["setSessionProperties"],
          hash["resetSessionProperties"],
          hash["setRoles"] && Hash[hash["setRoles"].to_a.map! {|k,v| [k, SelectedRole.decode(v)] }],
          hash["addedPreparedStatements"],
          hash["deallocatedPreparedStatements"],
          hash["startedTransactionId"],
          hash["clearTransactionId"],
          hash["updateType"],
          hash["outputStage"] && StageInfo.decode(hash["outputStage"]),
          hash["failureInfo"] && ExecutionFailureInfo.decode(hash["failureInfo"]),
          hash["errorCode"] && ErrorCode.decode(hash["errorCode"]),
          hash["warnings"] && hash["warnings"].map {|h| TrinoWarning.decode(h) },
          hash["inputs"] && hash["inputs"].map {|h| Input.decode(h) },
          hash["output"] && Output.decode(hash["output"]),
          hash["referencedTables"] && hash["referencedTables"].map {|h| TableInfo.decode(h) },
          hash["routines"] && hash["routines"].map {|h| RoutineInfo.decode(h) },
          hash["completeInfo"],
          hash["resourceGroupId"] && ResourceGroupId.new(hash["resourceGroupId"]),
          hash["queryType"] && hash["queryType"].downcase.to_sym,
          hash["finalQueryInfo"],
        )
        obj
      end
    end

    class << QueryResults =
        Base.new(:id, :info_uri, :partial_cancel_uri, :next_uri, :columns, :data, :stats, :error, :warnings, :update_type, :update_count)
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
          hash["warnings"] && hash["warnings"].map {|h| Warning.decode(h) },
          hash["updateType"],
          hash["updateCount"],
        )
        obj
      end
    end

    class << QueryStats =
        Base.new(:create_time, :execution_start_time, :last_heartbeat, :end_time, :elapsed_time, :queued_time, :resource_waiting_time, :dispatching_time, :execution_time, :analysis_time, :planning_time, :finishing_time, :total_tasks, :running_tasks, :completed_tasks, :total_drivers, :queued_drivers, :running_drivers, :blocked_drivers, :completed_drivers, :cumulative_user_memory, :user_memory_reservation, :revocable_memory_reservation, :total_memory_reservation, :peak_user_memory_reservation, :peak_revocable_memory_reservation, :peak_non_revocable_memory_reservation, :peak_total_memory_reservation, :peak_task_user_memory, :peak_task_revocable_memory, :peak_task_total_memory, :scheduled, :total_scheduled_time, :total_cpu_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :physical_input_data_size, :physical_input_positions, :physical_input_read_time, :internal_network_input_data_size, :internal_network_input_positions, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :physical_written_data_size, :stage_gc_statistics, :dynamic_filters_stats, :operator_summaries)
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
          hash["resourceWaitingTime"],
          hash["dispatchingTime"],
          hash["executionTime"],
          hash["analysisTime"],
          hash["planningTime"],
          hash["finishingTime"],
          hash["totalTasks"],
          hash["runningTasks"],
          hash["completedTasks"],
          hash["totalDrivers"],
          hash["queuedDrivers"],
          hash["runningDrivers"],
          hash["blockedDrivers"],
          hash["completedDrivers"],
          hash["cumulativeUserMemory"],
          hash["userMemoryReservation"],
          hash["revocableMemoryReservation"],
          hash["totalMemoryReservation"],
          hash["peakUserMemoryReservation"],
          hash["peakRevocableMemoryReservation"],
          hash["peakNonRevocableMemoryReservation"],
          hash["peakTotalMemoryReservation"],
          hash["peakTaskUserMemory"],
          hash["peakTaskRevocableMemory"],
          hash["peakTaskTotalMemory"],
          hash["scheduled"],
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalBlockedTime"],
          hash["fullyBlocked"],
          hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
          hash["physicalInputDataSize"],
          hash["physicalInputPositions"],
          hash["physicalInputReadTime"],
          hash["internalNetworkInputDataSize"],
          hash["internalNetworkInputPositions"],
          hash["rawInputDataSize"],
          hash["rawInputPositions"],
          hash["processedInputDataSize"],
          hash["processedInputPositions"],
          hash["outputDataSize"],
          hash["outputPositions"],
          hash["physicalWrittenDataSize"],
          hash["stageGcStatistics"] && hash["stageGcStatistics"].map {|h| StageGcStatistics.decode(h) },
          hash["dynamicFiltersStats"] && DynamicFiltersStats.decode(hash["dynamicFiltersStats"]),
          hash["operatorSummaries"] && hash["operatorSummaries"].map {|h| OperatorStats.decode(h) },
        )
        obj
      end
    end

    class << RefreshMaterializedViewTarget =
        Base.new(:table_handle, :insert_handle, :schema_table_name, :source_table_handles)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["tableHandle"] && TableHandle.decode(hash["tableHandle"]),
          hash["insertHandle"] && InsertTableHandle.decode(hash["insertHandle"]),
          hash["schemaTableName"] && SchemaTableName.decode(hash["schemaTableName"]),
          hash["sourceTableHandles"] && hash["sourceTableHandles"].map {|h| TableHandle.decode(h) },
        )
        obj
      end
    end

    class << RemoteSourceNode =
        Base.new(:id, :source_fragment_ids, :outputs, :ordering_scheme, :exchange_type)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["sourceFragmentIds"],
          hash["outputs"],
          hash["orderingScheme"] && OrderingScheme.decode(hash["orderingScheme"]),
          hash["exchangeType"] && hash["exchangeType"].downcase.to_sym,
        )
        obj
      end
    end

    class << ResolvedFunction =
        Base.new(:signature, :id, :type_dependencies, :function_dependencies)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["signature"] && BoundSignature.decode(hash["signature"]),
          hash["id"],
          hash["typeDependencies"],
          hash["functionDependencies"] && hash["functionDependencies"].map {|h| ResolvedFunction.decode(h) },
        )
        obj
      end
    end

    class << ResourceEstimates =
        Base.new(:execution_time, :cpu_time, :peak_memory_bytes)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["executionTime"],
          hash["cpuTime"],
          hash["peakMemoryBytes"],
        )
        obj
      end
    end

    class << RoutineInfo =
        Base.new(:routine, :authorization)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["routine"],
          hash["authorization"],
        )
        obj
      end
    end

    class << RowNumberNode =
        Base.new(:id, :source, :partition_by, :order_sensitive, :row_number_symbol, :max_row_count_per_partition, :hash_symbol)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["partitionBy"],
          hash["orderSensitive"],
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

    class << SelectedRole =
        Base.new(:type, :role)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["type"],
          hash["role"],
        )
        obj
      end
    end

    class << SemiJoinNode =
        Base.new(:id, :source, :filtering_source, :source_join_symbol, :filtering_source_join_symbol, :semi_join_output, :source_hash_symbol, :filtering_source_hash_symbol, :distribution_type, :dynamic_filter_id)
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
          hash["dynamicFilterId"],
        )
        obj
      end
    end

    class << SessionRepresentation =
        Base.new(:query_id, :transaction_id, :client_transaction_support, :user, :groups, :principal, :source, :catalog, :schema, :path, :trace_token, :time_zone_key, :locale, :remote_user_address, :user_agent, :client_info, :client_tags, :client_capabilities, :resource_estimates, :start, :system_properties, :catalog_properties, :unprocessed_catalog_properties, :roles, :prepared_statements, :protocol_name)
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
          hash["groups"],
          hash["principal"],
          hash["source"],
          hash["catalog"],
          hash["schema"],
          hash["path"] && SqlPath.decode(hash["path"]),
          hash["traceToken"],
          hash["timeZoneKey"],
          hash["locale"],
          hash["remoteUserAddress"],
          hash["userAgent"],
          hash["clientInfo"],
          hash["clientTags"],
          hash["clientCapabilities"],
          hash["resourceEstimates"] && ResourceEstimates.decode(hash["resourceEstimates"]),
          hash["start"],
          hash["systemProperties"],
          hash["catalogProperties"],
          hash["unprocessedCatalogProperties"],
          hash["roles"] && Hash[hash["roles"].to_a.map! {|k,v| [k, SelectedRole.decode(v)] }],
          hash["preparedStatements"],
          hash["protocolName"],
        )
        obj
      end
    end

    class << SortNode =
        Base.new(:id, :source, :ordering_scheme, :partial)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["orderingScheme"] && OrderingScheme.decode(hash["orderingScheme"]),
          hash["partial"],
        )
        obj
      end
    end

    class << SpatialJoinNode =
        Base.new(:id, :type, :left, :right, :output_symbols, :filter, :left_partition_symbol, :right_partition_symbol, :kdb_tree)
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
          hash["outputSymbols"],
          hash["filter"],
          hash["leftPartitionSymbol"],
          hash["rightPartitionSymbol"],
          hash["kdbTree"],
        )
        obj
      end
    end

    class << Specification =
        Base.new(:partition_by, :ordering_scheme)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["partitionBy"],
          hash["orderingScheme"] && OrderingScheme.decode(hash["orderingScheme"]),
        )
        obj
      end
    end

    class << SplitOperatorInfo =
        Base.new(:catalog_name, :split_info)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["catalogName"],
          hash["splitInfo"],
        )
        obj
      end
    end

    class << SqlPath =
        Base.new(:raw_path)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["rawPath"],
        )
        obj
      end
    end

    class << StageExecutionDescriptor =
        Base.new(:strategy, :grouped_execution_scan_nodes)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["strategy"] && hash["strategy"].downcase.to_sym,
          hash["groupedExecutionScanNodes"],
        )
        obj
      end
    end

    class << StageGcStatistics =
        Base.new(:stage_id, :tasks, :full_gc_tasks, :min_full_gc_sec, :max_full_gc_sec, :total_full_gc_sec, :average_full_gc_sec)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["stageId"],
          hash["tasks"],
          hash["fullGcTasks"],
          hash["minFullGcSec"],
          hash["maxFullGcSec"],
          hash["totalFullGcSec"],
          hash["averageFullGcSec"],
        )
        obj
      end
    end

    class << StageInfo =
        Base.new(:stage_id, :state, :plan, :types, :stage_stats, :tasks, :sub_stages, :tables, :failure_cause)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["stageId"] && StageId.new(hash["stageId"]),
          hash["state"] && hash["state"].downcase.to_sym,
          hash["plan"] && PlanFragment.decode(hash["plan"]),
          hash["types"],
          hash["stageStats"] && StageStats.decode(hash["stageStats"]),
          hash["tasks"] && hash["tasks"].map {|h| TaskInfo.decode(h) },
          hash["subStages"] && hash["subStages"].map {|h| StageInfo.decode(h) },
          hash["tables"] && Hash[hash["tables"].to_a.map! {|k,v| [k, TableInfo.decode(v)] }],
          hash["failureCause"] && ExecutionFailureInfo.decode(hash["failureCause"]),
        )
        obj
      end
    end

    class << StageStats =
        Base.new(:scheduling_complete, :get_split_distribution, :total_tasks, :running_tasks, :completed_tasks, :total_drivers, :queued_drivers, :running_drivers, :blocked_drivers, :completed_drivers, :cumulative_user_memory, :user_memory_reservation, :revocable_memory_reservation, :total_memory_reservation, :peak_user_memory_reservation, :peak_revocable_memory_reservation, :total_scheduled_time, :total_cpu_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :physical_input_data_size, :physical_input_positions, :physical_input_read_time, :internal_network_input_data_size, :internal_network_input_positions, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :buffered_data_size, :output_data_size, :output_positions, :physical_written_data_size, :gc_info, :operator_summaries)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["schedulingComplete"],
          hash["getSplitDistribution"] && DistributionSnapshot.decode(hash["getSplitDistribution"]),
          hash["totalTasks"],
          hash["runningTasks"],
          hash["completedTasks"],
          hash["totalDrivers"],
          hash["queuedDrivers"],
          hash["runningDrivers"],
          hash["blockedDrivers"],
          hash["completedDrivers"],
          hash["cumulativeUserMemory"],
          hash["userMemoryReservation"],
          hash["revocableMemoryReservation"],
          hash["totalMemoryReservation"],
          hash["peakUserMemoryReservation"],
          hash["peakRevocableMemoryReservation"],
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalBlockedTime"],
          hash["fullyBlocked"],
          hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
          hash["physicalInputDataSize"],
          hash["physicalInputPositions"],
          hash["physicalInputReadTime"],
          hash["internalNetworkInputDataSize"],
          hash["internalNetworkInputPositions"],
          hash["rawInputDataSize"],
          hash["rawInputPositions"],
          hash["processedInputDataSize"],
          hash["processedInputPositions"],
          hash["bufferedDataSize"],
          hash["outputDataSize"],
          hash["outputPositions"],
          hash["physicalWrittenDataSize"],
          hash["gcInfo"] && StageGcStatistics.decode(hash["gcInfo"]),
          hash["operatorSummaries"] && hash["operatorSummaries"].map {|h| OperatorStats.decode(h) },
        )
        obj
      end
    end

    class << StatementStats =
        Base.new(:state, :queued, :scheduled, :nodes, :total_splits, :queued_splits, :running_splits, :completed_splits, :cpu_time_millis, :wall_time_millis, :queued_time_millis, :elapsed_time_millis, :processed_rows, :processed_bytes, :physical_input_bytes, :peak_memory_bytes, :spilled_bytes, :root_stage)
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
          hash["cpuTimeMillis"],
          hash["wallTimeMillis"],
          hash["queuedTimeMillis"],
          hash["elapsedTimeMillis"],
          hash["processedRows"],
          hash["processedBytes"],
          hash["physicalInputBytes"],
          hash["peakMemoryBytes"],
          hash["spilledBytes"],
          hash["rootStage"] && ClientStageStats.decode(hash["rootStage"]),
        )
        obj
      end
    end

    class << StatisticAggregations =
        Base.new(:aggregations, :grouping_symbols)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["aggregations"] && Hash[hash["aggregations"].to_a.map! {|k,v| [k, Aggregation.decode(v)] }],
          hash["groupingSymbols"],
        )
        obj
      end
    end

    class << StatisticAggregationsDescriptor_Symbol =
        Base.new(:grouping, :table_statistics, :column_statistics)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["grouping"],
          hash["tableStatistics"] && Hash[hash["tableStatistics"].to_a.map! {|k,v| [k.downcase.to_sym, v] }],
          hash["columnStatistics"] && Hash[hash["columnStatistics"].to_a.map! {|k,v| [ColumnStatisticMetadata.decode(k), v] }],
        )
        obj
      end
    end

    class << StatisticsWriterNode =
        Base.new(:id, :source, :target, :row_count_symbol, :row_count_enabled, :descriptor)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["target"] && WriteStatisticsTarget.decode(hash["target"]),
          hash["rowCountSymbol"],
          hash["rowCountEnabled"],
          hash["descriptor"] && StatisticAggregationsDescriptor_Symbol.decode(hash["descriptor"]),
        )
        obj
      end
    end

    class << StatsAndCosts =
        Base.new(:stats, :costs)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["stats"] && Hash[hash["stats"].to_a.map! {|k,v| [k, PlanNodeStatsEstimate.decode(v)] }],
          hash["costs"] && Hash[hash["costs"].to_a.map! {|k,v| [k, PlanCostEstimate.decode(v)] }],
        )
        obj
      end
    end

    class << SymbolStatsEstimate =
        Base.new(:low_value, :high_value, :nulls_fraction, :average_row_size, :distinct_values_count)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["lowValue"],
          hash["highValue"],
          hash["nullsFraction"],
          hash["averageRowSize"],
          hash["distinctValuesCount"],
        )
        obj
      end
    end

    class << TableFinishInfo =
        Base.new(:connector_output_metadata, :json_length_limit_exceeded, :statistics_wall_time, :statistics_cpu_time)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["connectorOutputMetadata"],
          hash["jsonLengthLimitExceeded"],
          hash["statisticsWallTime"],
          hash["statisticsCpuTime"],
        )
        obj
      end
    end

    class << TableFinishNode =
        Base.new(:id, :source, :target, :row_count_symbol, :statistics_aggregation, :statistics_aggregation_descriptor)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["target"] && WriterTarget.decode(hash["target"]),
          hash["rowCountSymbol"],
          hash["statisticsAggregation"] && StatisticAggregations.decode(hash["statisticsAggregation"]),
          hash["statisticsAggregationDescriptor"] && StatisticAggregationsDescriptor_Symbol.decode(hash["statisticsAggregationDescriptor"]),
        )
        obj
      end
    end

    class << TableHandle =
        Base.new(:catalog_name, :connector_handle, :transaction, :layout)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["catalogName"],
          hash["connectorHandle"],
          hash["transaction"],
          hash["layout"],
        )
        obj
      end
    end

    class << TableInfo =
        Base.new(:table_name, :predicate)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["tableName"],
          hash["predicate"],
        )
        obj
      end
    end

    class << TableScanNode =
        Base.new(:id, :table, :output_symbols, :assignments, :for_delete)
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
          hash["forDelete"],
        )
        obj
      end
    end

    class << TableWriterInfo =
        Base.new(:page_sink_peak_memory_usage, :statistics_wall_time, :statistics_cpu_time, :validation_cpu_time)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["pageSinkPeakMemoryUsage"],
          hash["statisticsWallTime"],
          hash["statisticsCpuTime"],
          hash["validationCpuTime"],
        )
        obj
      end
    end

    class << TableWriterNode =
        Base.new(:id, :source, :target, :row_count_symbol, :fragment_symbol, :columns, :column_names, :not_null_column_symbols, :partitioning_scheme, :statistics_aggregation, :statistics_aggregation_descriptor)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["target"] && WriterTarget.decode(hash["target"]),
          hash["rowCountSymbol"],
          hash["fragmentSymbol"],
          hash["columns"],
          hash["columnNames"],
          hash["notNullColumnSymbols"],
          hash["partitioningScheme"] && PartitioningScheme.decode(hash["partitioningScheme"]),
          hash["statisticsAggregation"] && StatisticAggregations.decode(hash["statisticsAggregation"]),
          hash["statisticsAggregationDescriptor"] && StatisticAggregationsDescriptor_Symbol.decode(hash["statisticsAggregationDescriptor"]),
        )
        obj
      end
    end

    class << TaskInfo =
        Base.new(:task_status, :last_heartbeat, :output_buffers, :no_more_splits, :stats, :needs_plan)
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
        )
        obj
      end
    end

    class << TaskStats =
        Base.new(:create_time, :first_start_time, :last_start_time, :last_end_time, :end_time, :elapsed_time, :queued_time, :total_drivers, :queued_drivers, :queued_partitioned_drivers, :running_drivers, :running_partitioned_drivers, :blocked_drivers, :completed_drivers, :cumulative_user_memory, :user_memory_reservation, :revocable_memory_reservation, :system_memory_reservation, :total_scheduled_time, :total_cpu_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :physical_input_data_size, :physical_input_positions, :physical_input_read_time, :internal_network_input_data_size, :internal_network_input_positions, :raw_input_data_size, :raw_input_positions, :processed_input_data_size, :processed_input_positions, :output_data_size, :output_positions, :physical_written_data_size, :full_gc_count, :full_gc_time, :pipelines)
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
          hash["cumulativeUserMemory"],
          hash["userMemoryReservation"],
          hash["revocableMemoryReservation"],
          hash["systemMemoryReservation"],
          hash["totalScheduledTime"],
          hash["totalCpuTime"],
          hash["totalBlockedTime"],
          hash["fullyBlocked"],
          hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
          hash["physicalInputDataSize"],
          hash["physicalInputPositions"],
          hash["physicalInputReadTime"],
          hash["internalNetworkInputDataSize"],
          hash["internalNetworkInputPositions"],
          hash["rawInputDataSize"],
          hash["rawInputPositions"],
          hash["processedInputDataSize"],
          hash["processedInputPositions"],
          hash["outputDataSize"],
          hash["outputPositions"],
          hash["physicalWrittenDataSize"],
          hash["fullGcCount"],
          hash["fullGcTime"],
          hash["pipelines"] && hash["pipelines"].map {|h| PipelineStats.decode(h) },
        )
        obj
      end
    end

    class << TaskStatus =
        Base.new(:task_id, :task_instance_id, :version, :state, :self, :node_id, :completed_driver_groups, :failures, :queued_partitioned_drivers, :running_partitioned_drivers, :output_buffer_overutilized, :physical_written_data_size, :memory_reservation, :system_memory_reservation, :revocable_memory_reservation, :full_gc_count, :full_gc_time, :dynamic_filters_version)
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
          hash["nodeId"],
          hash["completedDriverGroups"] && hash["completedDriverGroups"].map {|h| Lifespan.new(h) },
          hash["failures"] && hash["failures"].map {|h| ExecutionFailureInfo.decode(h) },
          hash["queuedPartitionedDrivers"],
          hash["runningPartitionedDrivers"],
          hash["outputBufferOverutilized"],
          hash["physicalWrittenDataSize"],
          hash["memoryReservation"],
          hash["systemMemoryReservation"],
          hash["revocableMemoryReservation"],
          hash["fullGcCount"],
          hash["fullGcTime"],
          hash["dynamicFiltersVersion"],
        )
        obj
      end
    end

    class << TopNNode =
        Base.new(:id, :source, :count, :ordering_scheme, :step)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["count"],
          hash["orderingScheme"] && OrderingScheme.decode(hash["orderingScheme"]),
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

    class << TrinoWarning =
        Base.new(:warning_code, :message)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["warningCode"] && WarningCode.decode(hash["warningCode"]),
          hash["message"],
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
        Base.new(:id, :source, :replicate_symbols, :mappings, :ordinality_symbol, :join_type, :filter)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["source"] && PlanNode.decode(hash["source"]),
          hash["replicateSymbols"],
          hash["mappings"] && hash["mappings"].map {|h| Mapping.decode(h) },
          hash["ordinalitySymbol"],
          hash["joinType"],
          hash["filter"],
        )
        obj
      end
    end

    class << ValuesNode =
        Base.new(:id, :output_symbols, :row_count, :rows)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["id"],
          hash["outputSymbols"],
          hash["rowCount"],
          hash["rows"],
        )
        obj
      end
    end

    class << Warning =
        Base.new(:warning_code, :message)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["warningCode"] && Code.decode(hash["warningCode"]),
          hash["message"],
        )
        obj
      end
    end

    class << WarningCode =
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

    class << WindowInfo =
        Base.new(:window_infos)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["windowInfos"] && hash["windowInfos"].map {|h| DriverWindowInfo.decode(h) },
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

    class << WriteStatisticsHandle =
        Base.new(:handle)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["handle"] && AnalyzeTableHandle.decode(hash["handle"]),
        )
        obj
      end
    end


  end
end

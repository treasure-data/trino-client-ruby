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

  module V483
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

  class << BasicQueryInfo =
    Base.new(:query_id, :session, :resource_group_id, :state, :scheduled, :self, :query, :update_type, :prepared_query, :query_stats, :error_type, :error_code, :query_type, :retry_policy)
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
     hash["scheduled"],
     hash["self"],
     hash["query"],
     hash["updateType"],
     hash["preparedQuery"],
     hash["queryStats"] && BasicQueryStats.decode(hash["queryStats"]),
     hash["errorType"] && hash["errorType"].downcase.to_sym,
     hash["errorCode"] && ErrorCode.decode(hash["errorCode"]),
     hash["queryType"] && hash["queryType"].downcase.to_sym,
     hash["retryPolicy"] && hash["retryPolicy"].downcase.to_sym,
    )
    obj
   end
  end

  class << BasicQueryStats =
    Base.new(:create_time, :end_time, :queued_time, :resource_waiting_time, :elapsed_time, :execution_time, :failed_tasks, :total_drivers, :queued_drivers, :running_drivers, :completed_drivers, :blocked_drivers, :processed_input_positions, :spilled_data_size, :physical_input_data_size, :physical_written_data_size, :internal_network_input_data_size, :cumulative_user_memory, :failed_cumulative_user_memory, :user_memory_reservation, :total_memory_reservation, :peak_user_memory_reservation, :peak_total_memory_reservation, :planning_time, :analysis_time, :total_cpu_time, :failed_cpu_time, :total_scheduled_time, :failed_scheduled_time, :finishing_time, :physical_input_read_time, :fully_blocked, :blocked_reasons, :progress_percentage, :running_percentage)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["createTime"],
     hash["endTime"],
     hash["queuedTime"],
     hash["resourceWaitingTime"],
     hash["elapsedTime"],
     hash["executionTime"],
     hash["failedTasks"],
     hash["totalDrivers"],
     hash["queuedDrivers"],
     hash["runningDrivers"],
     hash["completedDrivers"],
     hash["blockedDrivers"],
     hash["processedInputPositions"],
     hash["spilledDataSize"],
     hash["physicalInputDataSize"],
     hash["physicalWrittenDataSize"],
     hash["internalNetworkInputDataSize"],
     hash["cumulativeUserMemory"],
     hash["failedCumulativeUserMemory"],
     hash["userMemoryReservation"],
     hash["totalMemoryReservation"],
     hash["peakUserMemoryReservation"],
     hash["peakTotalMemoryReservation"],
     hash["planningTime"],
     hash["analysisTime"],
     hash["totalCpuTime"],
     hash["failedCpuTime"],
     hash["totalScheduledTime"],
     hash["failedScheduledTime"],
     hash["finishingTime"],
     hash["physicalInputReadTime"],
     hash["fullyBlocked"],
     hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
     hash["progressPercentage"],
     hash["runningPercentage"],
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
     hash["name"] && CatalogSchemaFunctionName.decode(hash["name"]),
     hash["returnType"],
     hash["argumentTypes"],
    )
    obj
   end
  end

  class << CatalogHandle =
    Base.new(:id)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["id"],
    )
    obj
   end
  end

  class << CatalogSchemaFunctionName =
    Base.new(:catalog_name, :schema_name, :function_name)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["catalogName"],
     hash["schemaName"],
     hash["functionName"],
    )
    obj
   end
  end

  class << CatalogSchemaName =
    Base.new(:catalog_name, :schema_name)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["catalogName"],
     hash["schemaName"],
    )
    obj
   end
  end

  class << CatalogVersion =
    Base.new(:version)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["version"],
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
    Base.new(:stage_id, :state, :done, :nodes, :total_splits, :queued_splits, :running_splits, :completed_splits, :cpu_time_millis, :wall_time_millis, :processed_rows, :processed_bytes, :physical_input_bytes, :failed_tasks, :coordinator_only, :sub_stages)
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
     hash["failedTasks"],
     hash["coordinatorOnly"],
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

  class << ColumnDetail =
    Base.new(:catalog, :schema, :table, :column_name)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["catalog"],
     hash["schema"],
     hash["table"],
     hash["columnName"],
    )
    obj
   end
  end

  class << ColumnLineageInfo =
    Base.new(:name, :source_columns)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["name"],
     hash["sourceColumns"] && hash["sourceColumns"].map {|h| ColumnDetail.decode(h) },
    )
    obj
   end
  end

  class << DynamicFilterDomainStats =
    Base.new(:dynamic_filter_id, :simplified_domain, :collection_duration)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["dynamicFilterId"],
     hash["simplifiedDomain"],
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

  class << ErrorCode =
    Base.new(:code, :name, :type, :fatal)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["code"],
     hash["name"],
     hash["type"] && hash["type"].downcase.to_sym,
     hash["fatal"],
    )
    obj
   end
  end

  class << ErrorInfo =
    Base.new(:code, :name, :type)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["code"],
     hash["name"],
     hash["type"],
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

  class << FailureInfo =
    Base.new(:type, :message, :cause, :suppressed, :stack, :error_info, :error_location)
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
     hash["errorInfo"] && ErrorInfo.decode(hash["errorInfo"]),
     hash["errorLocation"] && ErrorLocation.decode(hash["errorLocation"]),
    )
    obj
   end
  end

  class << FunctionNullability =
    Base.new(:return_nullable, :argument_nullable)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["returnNullable"],
     hash["argumentNullable"],
    )
    obj
   end
  end

  class << Input =
    Base.new(:connector_name, :catalog_name, :catalog_version, :schema, :table, :connector_info, :columns, :fragment_id, :plan_node_id)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["connectorName"],
     hash["catalogName"],
     hash["catalogVersion"] && CatalogVersion.decode(hash["catalogVersion"]),
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

  class << OperatorStats =
    Base.new(:stage_id, :pipeline_id, :operator_id, :plan_node_id, :source_id, :operator_type, :total_drivers, :add_input_calls, :add_input_wall, :add_input_cpu, :physical_input_data_size, :physical_input_positions, :physical_input_read_time, :internal_network_input_data_size, :internal_network_input_positions, :input_data_size, :input_positions, :sum_squared_input_positions, :get_output_calls, :get_output_wall, :get_output_cpu, :output_data_size, :output_positions, :dynamic_filter_splits_processed, :metrics, :connector_metrics, :pipeline_metrics, :physical_written_data_size, :blocked_wall, :finish_calls, :finish_wall, :finish_cpu, :user_memory_reservation, :revocable_memory_reservation, :peak_user_memory_reservation, :peak_revocable_memory_reservation, :spilled_data_size, :blocked_reason, :info)
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
     hash["sourceId"],
     hash["operatorType"],
     hash["totalDrivers"],
     hash["addInputCalls"],
     hash["addInputWall"],
     hash["addInputCpu"],
     hash["physicalInputDataSize"],
     hash["physicalInputPositions"],
     hash["physicalInputReadTime"],
     hash["internalNetworkInputDataSize"],
     hash["internalNetworkInputPositions"],
     hash["inputDataSize"],
     hash["inputPositions"],
     hash["sumSquaredInputPositions"],
     hash["getOutputCalls"],
     hash["getOutputWall"],
     hash["getOutputCpu"],
     hash["outputDataSize"],
     hash["outputPositions"],
     hash["dynamicFilterSplitsProcessed"],
     hash["metrics"],
     hash["connectorMetrics"],
     hash["pipelineMetrics"],
     hash["physicalWrittenDataSize"],
     hash["blockedWall"],
     hash["finishCalls"],
     hash["finishWall"],
     hash["finishCpu"],
     hash["userMemoryReservation"],
     hash["revocableMemoryReservation"],
     hash["peakUserMemoryReservation"],
     hash["peakRevocableMemoryReservation"],
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
    Base.new(:catalog_name, :catalog_version, :schema, :table, :columns)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["catalogName"],
     hash["catalogVersion"] && CatalogVersion.decode(hash["catalogVersion"]),
     hash["schema"],
     hash["table"],
     hash["columns"] && hash["columns"].map {|h| OutputColumn.decode(h) },
    )
    obj
   end
  end

  class << OutputColumn =
    Base.new(:column, :source_columns)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["column"] && Column.decode(hash["column"]),
     hash["sourceColumns"] && hash["sourceColumns"].map {|h| SourceColumn.decode(h) },
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
    Base.new(:query_id, :session, :state, :self, :field_names, :query, :prepared_query, :query_stats, :set_catalog, :set_schema, :set_path, :set_authorization_user, :reset_authorization_user, :set_original_roles, :set_session_properties, :reset_session_properties, :set_roles, :added_prepared_statements, :deallocated_prepared_statements, :started_transaction_id, :clear_transaction_id, :update_type, :stages, :failure_info, :error_code, :warnings, :inputs, :output, :select_columns_lineage_info, :referenced_tables, :routines, :final_query_info, :resource_group_id, :query_type, :retry_policy, :pruned, :version)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["queryId"],
     hash["session"] && SessionRepresentation.decode(hash["session"]),
     hash["state"] && hash["state"].downcase.to_sym,
     hash["self"],
     hash["fieldNames"],
     hash["query"],
     hash["preparedQuery"],
     hash["queryStats"] && QueryStats.decode(hash["queryStats"]),
     hash["setCatalog"],
     hash["setSchema"],
     hash["setPath"],
     hash["setAuthorizationUser"],
     hash["resetAuthorizationUser"],
     hash["setOriginalRoles"] && hash["setOriginalRoles"].map {|h| SelectedRole.decode(h) },
     hash["setSessionProperties"],
     hash["resetSessionProperties"],
     hash["setRoles"] && Hash[hash["setRoles"].to_a.map! {|k,v| [k, SelectedRole.decode(v)] }],
     hash["addedPreparedStatements"],
     hash["deallocatedPreparedStatements"],
     hash["startedTransactionId"],
     hash["clearTransactionId"],
     hash["updateType"],
     hash["stages"] && StagesInfo.decode(hash["stages"]),
     hash["failureInfo"] && ExecutionFailureInfo.decode(hash["failureInfo"]),
     hash["errorCode"] && ErrorCode.decode(hash["errorCode"]),
     hash["warnings"] && hash["warnings"].map {|h| TrinoWarning.decode(h) },
     hash["inputs"] && hash["inputs"].map {|h| Input.decode(h) },
     hash["output"] && Output.decode(hash["output"]),
     hash["selectColumnsLineageInfo"] && hash["selectColumnsLineageInfo"].map {|h| ColumnLineageInfo.decode(h) },
     hash["referencedTables"] && hash["referencedTables"].map {|h| TableInfo.decode(h) },
     hash["routines"] && hash["routines"].map {|h| RoutineInfo.decode(h) },
     hash["finalQueryInfo"],
     hash["resourceGroupId"] && ResourceGroupId.new(hash["resourceGroupId"]),
     hash["queryType"] && hash["queryType"].downcase.to_sym,
     hash["retryPolicy"] && hash["retryPolicy"].downcase.to_sym,
     hash["pruned"],
     hash["version"],
    )
    obj
   end
  end

  class << QueryPlanOptimizerStatistics =
    Base.new(:rule, :invocations, :applied, :total_time, :failures)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["rule"],
     hash["invocations"],
     hash["applied"],
     hash["totalTime"],
     hash["failures"],
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
    Base.new(:create_time, :execution_start_time, :last_heartbeat, :end_time, :elapsed_time, :queued_time, :resource_waiting_time, :dispatching_time, :execution_time, :analysis_time, :planning_time, :planning_cpu_time, :starting_time, :finishing_time, :total_tasks, :running_tasks, :completed_tasks, :failed_tasks, :total_drivers, :queued_drivers, :running_drivers, :blocked_drivers, :completed_drivers, :cumulative_user_memory, :failed_cumulative_user_memory, :user_memory_reservation, :revocable_memory_reservation, :total_memory_reservation, :peak_user_memory_reservation, :peak_revocable_memory_reservation, :peak_total_memory_reservation, :peak_task_user_memory, :peak_task_revocable_memory, :peak_task_total_memory, :spilled_data_size, :scheduled, :progress_percentage, :running_percentage, :total_scheduled_time, :failed_scheduled_time, :total_cpu_time, :failed_cpu_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :physical_input_data_size, :failed_physical_input_data_size, :physical_input_positions, :failed_physical_input_positions, :physical_input_read_time, :failed_physical_input_read_time, :internal_network_input_data_size, :failed_internal_network_input_data_size, :internal_network_input_positions, :failed_internal_network_input_positions, :processed_input_data_size, :failed_processed_input_data_size, :processed_input_positions, :failed_processed_input_positions, :input_blocked_time, :failed_input_blocked_time, :output_data_size, :failed_output_data_size, :output_positions, :failed_output_positions, :output_blocked_time, :failed_output_blocked_time, :physical_written_data_size, :failed_physical_written_data_size, :stage_gc_statistics, :dynamic_filters_stats, :catalog_metadata_metrics, :exchange_metrics, :operator_summaries, :optimizer_rules_summaries)
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
     hash["planningCpuTime"],
     hash["startingTime"],
     hash["finishingTime"],
     hash["totalTasks"],
     hash["runningTasks"],
     hash["completedTasks"],
     hash["failedTasks"],
     hash["totalDrivers"],
     hash["queuedDrivers"],
     hash["runningDrivers"],
     hash["blockedDrivers"],
     hash["completedDrivers"],
     hash["cumulativeUserMemory"],
     hash["failedCumulativeUserMemory"],
     hash["userMemoryReservation"],
     hash["revocableMemoryReservation"],
     hash["totalMemoryReservation"],
     hash["peakUserMemoryReservation"],
     hash["peakRevocableMemoryReservation"],
     hash["peakTotalMemoryReservation"],
     hash["peakTaskUserMemory"],
     hash["peakTaskRevocableMemory"],
     hash["peakTaskTotalMemory"],
     hash["spilledDataSize"],
     hash["scheduled"],
     hash["progressPercentage"],
     hash["runningPercentage"],
     hash["totalScheduledTime"],
     hash["failedScheduledTime"],
     hash["totalCpuTime"],
     hash["failedCpuTime"],
     hash["totalBlockedTime"],
     hash["fullyBlocked"],
     hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
     hash["physicalInputDataSize"],
     hash["failedPhysicalInputDataSize"],
     hash["physicalInputPositions"],
     hash["failedPhysicalInputPositions"],
     hash["physicalInputReadTime"],
     hash["failedPhysicalInputReadTime"],
     hash["internalNetworkInputDataSize"],
     hash["failedInternalNetworkInputDataSize"],
     hash["internalNetworkInputPositions"],
     hash["failedInternalNetworkInputPositions"],
     hash["processedInputDataSize"],
     hash["failedProcessedInputDataSize"],
     hash["processedInputPositions"],
     hash["failedProcessedInputPositions"],
     hash["inputBlockedTime"],
     hash["failedInputBlockedTime"],
     hash["outputDataSize"],
     hash["failedOutputDataSize"],
     hash["outputPositions"],
     hash["failedOutputPositions"],
     hash["outputBlockedTime"],
     hash["failedOutputBlockedTime"],
     hash["physicalWrittenDataSize"],
     hash["failedPhysicalWrittenDataSize"],
     hash["stageGcStatistics"] && hash["stageGcStatistics"].map {|h| StageGcStatistics.decode(h) },
     hash["dynamicFiltersStats"] && DynamicFiltersStats.decode(hash["dynamicFiltersStats"]),
     hash["catalogMetadataMetrics"],
     hash["exchangeMetrics"],
     hash["operatorSummaries"] && hash["operatorSummaries"].map {|h| OperatorStats.decode(h) },
     hash["optimizerRulesSummaries"] && hash["optimizerRulesSummaries"].map {|h| QueryPlanOptimizerStatistics.decode(h) },
    )
    obj
   end
  end

  class << ResolvedFunction =
    Base.new(:signature, :catalog_handle, :function_id, :function_kind, :deterministic, :never_fails, :function_nullability, :type_dependencies, :function_dependencies)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["signature"] && BoundSignature.decode(hash["signature"]),
     hash["catalogHandle"] && CatalogHandle.decode(hash["catalogHandle"]),
     hash["functionId"],
     hash["functionKind"] && hash["functionKind"].downcase.to_sym,
     hash["deterministic"],
     hash["neverFails"],
     hash["functionNullability"] && FunctionNullability.decode(hash["functionNullability"]),
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

  class << SessionRepresentation =
    Base.new(:query_id, :query_span, :transaction_id, :client_transaction_support, :user, :original_user, :set_original_roles, :groups, :original_user_groups, :principal, :enabled_roles, :source, :catalog, :schema, :path, :trace_token, :time_zone_key, :locale, :remote_user_address, :user_agent, :client_info, :client_tags, :client_capabilities, :resource_estimates, :start, :system_properties, :catalog_properties, :catalog_roles, :prepared_statements, :protocol_name, :query_data_encoding)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["queryId"],
     hash["querySpan"],
     hash["transactionId"],
     hash["clientTransactionSupport"],
     hash["user"],
     hash["originalUser"],
     hash["setOriginalRoles"],
     hash["groups"],
     hash["originalUserGroups"],
     hash["principal"],
     hash["enabledRoles"],
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
     hash["catalogRoles"] && Hash[hash["catalogRoles"].to_a.map! {|k,v| [k, SelectedRole.decode(v)] }],
     hash["preparedStatements"],
     hash["protocolName"],
     hash["queryDataEncoding"],
    )
    obj
   end
  end

  class << SourceColumn =
    Base.new(:table_name, :column_name)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["tableName"],
     hash["columnName"],
    )
    obj
   end
  end

  class << SqlPath =
    Base.new(:path, :raw_path)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["path"] && hash["path"].map {|h| CatalogSchemaName.decode(h) },
     hash["rawPath"],
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
    Base.new(:stage_id, :state, :plan, :coordinator_only, :types, :stage_stats, :tasks, :sub_stages, :tables, :failure_cause)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["stageId"] && StageId.new(hash["stageId"]),
     hash["state"] && hash["state"].downcase.to_sym,
     hash["plan"],
     hash["coordinatorOnly"],
     hash["types"],
     hash["stageStats"] && StageStats.decode(hash["stageStats"]),
     hash["tasks"],
     hash["subStages"] && hash["subStages"].map {|h| StageId.new(h) },
     hash["tables"] && Hash[hash["tables"].to_a.map! {|k,v| [k, TableInfo.decode(v)] }],
     hash["failureCause"] && ExecutionFailureInfo.decode(hash["failureCause"]),
    )
    obj
   end
  end

  class << StageStats =
    Base.new(:scheduling_complete, :get_split_distribution, :split_source_metrics, :total_tasks, :running_tasks, :completed_tasks, :failed_tasks, :total_drivers, :queued_drivers, :running_drivers, :blocked_drivers, :completed_drivers, :cumulative_user_memory, :failed_cumulative_user_memory, :user_memory_reservation, :revocable_memory_reservation, :total_memory_reservation, :peak_user_memory_reservation, :peak_revocable_memory_reservation, :spilled_data_size, :total_scheduled_time, :failed_scheduled_time, :total_cpu_time, :failed_cpu_time, :total_blocked_time, :fully_blocked, :blocked_reasons, :physical_input_data_size, :failed_physical_input_data_size, :physical_input_positions, :failed_physical_input_positions, :physical_input_read_time, :failed_physical_input_read_time, :internal_network_input_data_size, :failed_internal_network_input_data_size, :internal_network_input_positions, :failed_internal_network_input_positions, :processed_input_data_size, :failed_processed_input_data_size, :processed_input_positions, :failed_processed_input_positions, :input_blocked_time, :failed_input_blocked_time, :buffered_data_size, :output_buffer_utilization, :output_data_size, :failed_output_data_size, :output_positions, :failed_output_positions, :output_buffer_metrics, :output_blocked_time, :failed_output_blocked_time, :physical_written_data_size, :failed_physical_written_data_size, :gc_info, :operator_summaries)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["schedulingComplete"],
     hash["getSplitDistribution"],
     hash["splitSourceMetrics"],
     hash["totalTasks"],
     hash["runningTasks"],
     hash["completedTasks"],
     hash["failedTasks"],
     hash["totalDrivers"],
     hash["queuedDrivers"],
     hash["runningDrivers"],
     hash["blockedDrivers"],
     hash["completedDrivers"],
     hash["cumulativeUserMemory"],
     hash["failedCumulativeUserMemory"],
     hash["userMemoryReservation"],
     hash["revocableMemoryReservation"],
     hash["totalMemoryReservation"],
     hash["peakUserMemoryReservation"],
     hash["peakRevocableMemoryReservation"],
     hash["spilledDataSize"],
     hash["totalScheduledTime"],
     hash["failedScheduledTime"],
     hash["totalCpuTime"],
     hash["failedCpuTime"],
     hash["totalBlockedTime"],
     hash["fullyBlocked"],
     hash["blockedReasons"] && hash["blockedReasons"].map {|h| h.downcase.to_sym },
     hash["physicalInputDataSize"],
     hash["failedPhysicalInputDataSize"],
     hash["physicalInputPositions"],
     hash["failedPhysicalInputPositions"],
     hash["physicalInputReadTime"],
     hash["failedPhysicalInputReadTime"],
     hash["internalNetworkInputDataSize"],
     hash["failedInternalNetworkInputDataSize"],
     hash["internalNetworkInputPositions"],
     hash["failedInternalNetworkInputPositions"],
     hash["processedInputDataSize"],
     hash["failedProcessedInputDataSize"],
     hash["processedInputPositions"],
     hash["failedProcessedInputPositions"],
     hash["inputBlockedTime"],
     hash["failedInputBlockedTime"],
     hash["bufferedDataSize"],
     hash["outputBufferUtilization"],
     hash["outputDataSize"],
     hash["failedOutputDataSize"],
     hash["outputPositions"],
     hash["failedOutputPositions"],
     hash["outputBufferMetrics"],
     hash["outputBlockedTime"],
     hash["failedOutputBlockedTime"],
     hash["physicalWrittenDataSize"],
     hash["failedPhysicalWrittenDataSize"],
     hash["gcInfo"] && StageGcStatistics.decode(hash["gcInfo"]),
     hash["operatorSummaries"] && hash["operatorSummaries"].map {|h| OperatorStats.decode(h) },
    )
    obj
   end
  end

  class << StagesInfo =
    Base.new(:output_stage_id, :stages)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["outputStageId"] && StageId.new(hash["outputStageId"]),
     hash["stages"] && hash["stages"].map {|h| StageInfo.decode(h) },
    )
    obj
   end
  end

  class << StatementStats =
    Base.new(:state, :queued, :scheduled, :progress_percentage, :running_percentage, :nodes, :total_splits, :queued_splits, :running_splits, :completed_splits, :planning_time_millis, :analysis_time_millis, :cpu_time_millis, :wall_time_millis, :queued_time_millis, :elapsed_time_millis, :finishing_time_millis, :physical_input_time_millis, :processed_rows, :processed_bytes, :physical_input_bytes, :physical_written_bytes, :internal_network_input_bytes, :peak_memory_bytes, :spilled_bytes, :root_stage)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["state"],
     hash["queued"],
     hash["scheduled"],
     hash["progressPercentage"],
     hash["runningPercentage"],
     hash["nodes"],
     hash["totalSplits"],
     hash["queuedSplits"],
     hash["runningSplits"],
     hash["completedSplits"],
     hash["planningTimeMillis"],
     hash["analysisTimeMillis"],
     hash["cpuTimeMillis"],
     hash["wallTimeMillis"],
     hash["queuedTimeMillis"],
     hash["elapsedTimeMillis"],
     hash["finishingTimeMillis"],
     hash["physicalInputTimeMillis"],
     hash["processedRows"],
     hash["processedBytes"],
     hash["physicalInputBytes"],
     hash["physicalWrittenBytes"],
     hash["internalNetworkInputBytes"],
     hash["peakMemoryBytes"],
     hash["spilledBytes"],
     hash["rootStage"] && ClientStageStats.decode(hash["rootStage"]),
    )
    obj
   end
  end

  class << TableInfo =
    Base.new(:catalog, :schema, :table, :authorization, :filters, :columns, :directly_referenced, :view_text, :reference_chain)
   def decode(hash)
    unless hash.is_a?(Hash)
     raise TypeError, "Can't convert #{hash.class} to Hash"
    end
    obj = allocate
    obj.send(:initialize_struct,
     hash["catalog"],
     hash["schema"],
     hash["table"],
     hash["authorization"],
     hash["filters"],
     hash["columns"],
     hash["directlyReferenced"],
     hash["viewText"],
     hash["referenceChain"],
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


  end
end

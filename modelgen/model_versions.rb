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
module Presto::Client::ModelVersions

  ####
  ## lib/presto/client/model_versions/*.rb is automatically generated using "rake modelgen:all" command.
  ## You should not edit this file directly. To modify the class definitions, edit
  ## modelgen/model_versions.rb file and run "rake modelgen:all".
  ##

  module V<%= @model_version.gsub(".", "_") %>
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

    # Inner classes 
    class << Specification =
        Base.new(:partition_by, :order_by, :orderings, :frame, :pages_added)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["partitionBy"],
          hash["orderBy"],
          hash["orderings"],
          hash["frame"],
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
          hash["constant"]
        )
        obj
      end
    end

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
          hash["mask"] 
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
          hash["function_call"],
          hash["signature"] && Signature.decode(hash["signature"]),
          hash["frame"]  && Frame.decode(hash["frame"])
        )
        obj
      end
    end

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

    class << PartitionedOutputInfo =
        Base.new(:rows_added, :pages_added)
      def decode(hash)
        unless hash.is_a?(Hash)
          raise TypeError, "Can't convert #{hash.class} to Hash"
        end
        obj = allocate
        obj.send(:initialize_struct,
          hash["rows_added"],
          hash["pages_added"],
        )
        obj
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

<%= @contents %>
  end
end

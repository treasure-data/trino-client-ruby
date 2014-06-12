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
          when "sink"               then SinkNode
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

    ##
    # Those model classes are automatically generated
    #

<%= @contents %>
  end
end

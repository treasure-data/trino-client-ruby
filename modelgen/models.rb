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

<%= @contents %>
end

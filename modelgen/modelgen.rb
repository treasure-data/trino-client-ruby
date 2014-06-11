
if ARGV.length != 3
  puts "usage: <presto-source-dir> <template.erb> <output.rb>"
end

source_dir, template_path, output_path = *ARGV

require_relative 'presto_models'

require 'erb'
erb = ERB.new(File.read(template_path))

source_path = "/Users/frsyuki/project/presto-client-ruby/presto"

predefined_simple_classes = %w[QueryId StageId TaskId PlanNodeId PlanFragmentId ConnectorSession]
predefined_models = %w[DistributionSnapshot PlanNode]

assume_primitive = %w[Object Type Symbol URI Duration DataSize DateTime ConnectorTableHandle ConnectorOutputTableHandle ConnectorIndexHandle ConnectorColumnHandle Expression FunctionCall]
enum_types = %w[QueryState StageState TaskState QueueState PlanDistribution OutputPartitioning Step SortOrder]

root_models = %w[QueryResults QueryInfo] + %w[
OutputNode
ProjectNode
TableScanNode
ValuesNode
AggregationNode
MarkDistinctNode
MaterializeSampleNode
FilterNode
WindowNode
LimitNode
DistinctLimitNode
TopNNode
SampleNode
SortNode
ExchangeNode
SinkNode
JoinNode
SemiJoinNode
IndexJoinNode
IndexSourceNode
TableWriterNode
TableCommitNode
]

analyzer = PrestoModels::ModelAnalyzer.new(
  source_path,
  skip_models: predefined_models + predefined_simple_classes + assume_primitive + enum_types
)
analyzer.analyze(root_models)
models = analyzer.models
skipped_models = analyzer.skipped_models

formatter = PrestoModels::ModelFormatter.new(
  base_indent_count: 2,
  struct_class: "Base",
  special_struct_initialize_method: "initialize_struct",
  primitive_types: assume_primitive,
  skip_types: skipped_models,
  simple_classes: predefined_simple_classes,
  enum_types: enum_types,
)
formatter.format(models)

@contents = formatter.contents

data = erb.result
File.open(output_path, 'w') {|f| f.write data }



if ARGV.length != 3
  puts "usage: <presto-source-dir> <template.erb> <output.rb>"
end

source_dir, template_path, output_path = *ARGV

require_relative 'presto_models'

require 'erb'
erb = ERB.new(File.read(template_path))

source_path = source_dir

predefined_simple_classes = %w[StageId TaskId ConnectorSession]
predefined_models = %w[DistributionSnapshot PlanNode EquiJoinClause WriterTarget PageBufferInfo DeleteHandle]

assume_primitive = %w[Object Type Long Symbol QueryId PlanNodeId PlanFragmentId MemoryPoolId TransactionId URI Duration DataSize DateTime ColumnHandle ConnectorTableHandle ConnectorOutputTableHandle ConnectorIndexHandle ConnectorColumnHandle ConnectorInsertTableHandle ConnectorTableLayoutHandle Expression FunctionCall TimeZoneKey Locale TypeSignature Frame TupleDomain<ColumnHandle> SerializableNativeValue ConnectorTransactionHandle]
enum_types = %w[QueryState StageState TaskState QueueState PlanDistribution OutputPartitioning Step SortOrder BufferState NullPartitioning BlockedReason ParameterKind FunctionKind PartitionFunctionHandle]

root_models = %w[QueryResults QueryInfo] + %w[
OutputNode
ProjectNode
TableScanNode
ValuesNode
AggregationNode
MarkDistinctNode
FilterNode
WindowNode
RowNumberNode
TopNRowNumberNode
LimitNode
DistinctLimitNode
TopNNode
SampleNode
SortNode
RemoteSourceNode
JoinNode
SemiJoinNode
IndexJoinNode
IndexSourceNode
TableWriterNode
DeleteNode
MetadataDeleteNode
TableFinishNode
UnnestNode
ExchangeNode
UnionNode
EnforceSingleRowNode
] + %w[InsertTableHandle OutputTableHandle TableHandle]

name_mapping = Hash[*%w[
StatementStats StageStats ClientStageStats
ClientStageStats StageStats ClientStageStats
QueryResults Column ClientColumn
].each_slice(3).map { |x, y, z| [[x,y], z] }.flatten(1)]

path_mapping = Hash[*%w[
ClientColumn presto-client/src/main/java/com/facebook/presto/client/Column.java
ClientStageStats presto-client/src/main/java/com/facebook/presto/client/StageStats.java
Column presto-main/src/main/java/com/facebook/presto/execution/Column.java
QueryStats presto-main/src/main/java/com/facebook/presto/execution/QueryStats.java
StageStats presto-main/src/main/java/com/facebook/presto/execution/StageStats.java
].map.with_index { |v,i| i % 2 == 0 ? v : (source_path + "/" + v) }]

analyzer = PrestoModels::ModelAnalyzer.new(
  source_path,
  skip_models: predefined_models + predefined_simple_classes + assume_primitive + enum_types,
  path_mapping: path_mapping,
  name_mapping: name_mapping
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


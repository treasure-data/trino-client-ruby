
if ARGV.length != 4
  puts "usage: <model-version> <presto-source-dir> <template.erb> <output.rb>"
  exit 1
end

model_version, source_dir, template_path, output_path = *ARGV

require_relative 'presto_models'

require 'erb'
erb = ERB.new(File.read(template_path))

source_path = source_dir

predefined_simple_classes = %w[StageId TaskId Lifespan ConnectorSession ResourceGroupId]
predefined_models = %w[DistributionSnapshot PlanNode EquiJoinClause WriterTarget WriteStatisticsTarget OperatorInfo HashCollisionsInfo]

assume_primitive = %w[Object Type Long Symbol QueryId PlanNodeId PlanFragmentId MemoryPoolId TransactionId URI Duration DataSize DateTime ColumnHandle ConnectorTableHandle ConnectorOutputTableHandle ConnectorIndexHandle ConnectorColumnHandle ConnectorInsertTableHandle ConnectorTableLayoutHandle Expression FunctionCall TimeZoneKey Locale TypeSignature Frame TupleDomain<ColumnHandle> SerializableNativeValue ConnectorTransactionHandle OutputBufferId ConnectorPartitioningHandle NullableValue ConnectorId HostAddress JsonNode Node CatalogName QualifiedObjectName]
enum_types = %w[QueryState StageState TaskState QueueState PlanDistribution OutputPartitioning Step SortOrder BufferState NullPartitioning BlockedReason ParameterKind FunctionKind PartitionFunctionHandle Scope ErrorType DistributionType PipelineExecutionStrategy JoinType ExchangeNode.Type ColumnStatisticType TableStatisticType StageExecutionStrategy SemanticErrorCode]

root_models = %w[QueryResults QueryInfo BasicQueryInfo] + %w[
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
TableFinishNode
UnnestNode
ExchangeNode
UnionNode
IntersectNode
EnforceSingleRowNode
GroupIdNode
ExplainAnalyzeNode
ApplyNode
AssignUniqueId
LateralJoinNode
StatisticsWriterNode
] + %w[
ExchangeClientStatus
LocalExchangeBufferInfo
TableFinishInfo
SplitOperatorInfo
PartitionedOutputInfo
JoinOperatorInfo
WindowInfo
TableWriterInfo
]

name_mapping = Hash[*%w[
StatementStats StageStats ClientStageStats
ClientStageStats StageStats ClientStageStats
QueryResults Column ClientColumn
].each_slice(3).map { |x, y, z| [[x,y], z] }.flatten(1)]

path_mapping = Hash[*%w[
ClientColumn presto-client/src/main/java/io/prestosql/client/Column.java
ClientStageStats presto-client/src/main/java/io/prestosql/client/StageStats.java
Column presto-main/src/main/java/io/prestosql/execution/Column.java
QueryStats presto-main/src/main/java/io/prestosql/execution/QueryStats.java
StageStats presto-main/src/main/java/io/prestosql/execution/StageStats.java
PartitionedOutputInfo presto-main/src/main/java/io/prestosql/operator/PartitionedOutputOperator.java
TableWriterInfo presto-main/src/main/java/io/prestosql/operator/TableWriterOperator.java
TableInfo presto-main/src/main/java/io/prestosql/execution/TableInfo.java
].map.with_index { |v,i| i % 2 == 0 ? v : (source_path + "/" + v) }]

# model => [ [key,nullable,type], ... ]
extra_fields = {
    'QueryInfo' => [['finalQueryInfo', nil, 'boolean']]
}

analyzer = PrestoModels::ModelAnalyzer.new(
  source_path,
  skip_models: predefined_models + predefined_simple_classes + assume_primitive + enum_types,
  path_mapping: path_mapping,
  name_mapping: name_mapping,
  extra_fields: extra_fields
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
@model_version = model_version

data = erb.result
File.write(output_path, data)


# frozen_string_literal: true

require "erb"
require "fileutils"
require "json"

require_relative "schema_formatter"

if ARGV.length != 3
  warn <<~USAGE
    Usage:
      ruby modelgen/generate_from_schema.rb \
        <version> \
        <schema.json> \
        <output.rb>
  USAGE

  exit 1
end

model_version, schema_path, output_path = ARGV

schema = JSON.parse(
  File.read(schema_path),
  )

schema_version = schema.fetch(
  "trinoVersion",
  )

unless schema_version == model_version
  raise ArgumentError,
        "Version mismatch: argument=#{model_version.inspect}, " \
          "schema=#{schema_version.inspect}"
end

formatter = TrinoModels::SchemaFormatter.new(
  schema,
  )

@contents = formatter.format
@model_version = model_version

template_path = File.expand_path(
  "model_versions.rb",
  __dir__,
  )

template = ERB.new(
  File.read(template_path),
  )

FileUtils.mkdir_p(
  File.dirname(output_path),
  )

File.write(
  output_path,
  template.result(binding),
  )

puts "Generated #{output_path}."
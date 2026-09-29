# frozen_string_literal: true

require "json"

if ARGV.length != 3
  warn <<~USAGE
    Usage:
      ruby modelgen/compare_model_shapes.rb \
        <version> \
        <old-model.rb> \
        <new-model.rb>
  USAGE

  exit 1
end

version, old_path, new_path = ARGV

module Trino
  module Client
    module ModelVersions
    end
  end
end

module_name = :"V#{version.tr('.', '_')}"

def capture_shape(
  module_name:,
  path:
)
  model_versions =
    Trino::Client::ModelVersions

  if model_versions.const_defined?(
    module_name,
    false,
    )
    model_versions.send(
      :remove_const,
      module_name,
      )
  end

  load File.expand_path(path)

  version_module = model_versions.const_get(
    module_name,
    false,
    )

  shape = {}

  version_module
    .constants(false)
    .sort
    .each do |constant_name|
    value = version_module.const_get(
      constant_name,
      false,
      )

    next unless value.respond_to?(:members)

    shape[constant_name.to_s] =
      value.members.map(&:to_s)
  end

  model_versions.send(
    :remove_const,
    module_name,
    )

  shape
end

old_shape = capture_shape(
  module_name: module_name,
  path: old_path,
  )

new_shape = capture_shape(
  module_name: module_name,
  path: new_path,
  )

missing_models =
  old_shape.keys - new_shape.keys

added_models =
  new_shape.keys - old_shape.keys

missing_fields = {}
added_fields = {}

(old_shape.keys & new_shape.keys).each do |model|
  old_fields = old_shape.fetch(model)
  new_fields = new_shape.fetch(model)

  missing = old_fields - new_fields
  added = new_fields - old_fields

  missing_fields[model] = missing \
    unless missing.empty?

  added_fields[model] = added \
    unless added.empty?
end

result = {
  missingModels: missing_models.sort,
  addedModels: added_models.sort,
  missingFields: missing_fields,
  addedFields: added_fields,
}

puts JSON.pretty_generate(result)

has_regression =
  !missing_models.empty? ||
  !missing_fields.empty?

if has_regression
  warn "Compatibility check failed."
  exit 1
end

puts "Compatibility check passed."
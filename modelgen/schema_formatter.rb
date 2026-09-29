# frozen_string_literal: true

require "set"

module TrinoModels
  # Converts the JSON intermediate representation produced by the Java
  # extractor into Ruby model definitions embedded by model_versions.rb.
  class SchemaFormatter
    PREDEFINED_MODELS = Set.new(
      %w[
        DistributionSnapshot
        PlanNode
        EquiJoinClause
        WriterTarget
        WriteStatisticsTarget
        OperatorInfo
        HashCollisionsInfo
      ]
    ).freeze

    PREDEFINED_SIMPLE_CLASSES = Set.new(
      %w[
        StageId
        TaskId
        Lifespan
        ConnectorSession
        ResourceGroupId
      ]
    ).freeze

    # Preserve existing trino-client-ruby names where Java packages contain
    # classes with the same simple name.
    MODEL_ALIASES = {
      "io.trino.client.Column" => "ClientColumn",
      "io.trino.execution.Column" => "Column",
      "io.trino.client.StageStats" => "ClientStageStats",
      "io.trino.execution.StageStats" => "StageStats",
      "io.trino.execution.TableInfo" => "TableInfo",
      "io.trino.spi.eventlistener.TableInfo" => "EventListenerTableInfo",
      "io.trino.sql.planner.plan.StatisticAggregationsDescriptor" => "StatisticAggregationsDescriptor_Symbol"
    }.freeze

    # Preserve wrappers that are part of the existing Ruby API. Other
    # @JsonValue-backed Java types are represented by their wire values.
    VALUE_WRAPPERS = {
      "io.trino.spi.resourcegroups.ResourceGroupId" => "ResourceGroupId"
    }.freeze

    SUPPORTED_SCHEMA_VERSIONS = [1].freeze

    LEGACY_EXTRA_PROPERTIES = {
      "351" => {
        "io.trino.execution.QueryInfo" => [
          {
            "jsonName" => "finalQueryInfo",
            "javaName" => "finalQueryInfo",
            "creatorIndex" => 10_000,
            "nullability" => "non_null",
            "type" => {
              "kind" => "primitive",
              "name" => "boolean"
            }
          }
        ]
      }
    }.freeze

    def initialize(schema)
      @schema = schema
      validate_schema!

      @models_by_java_name = @schema.fetch("models").each_with_object({}) do |model, result|
        result[model.fetch("javaName")] = model
      end

      validate_generated_name_uniqueness!
    end

    def format
      models = @schema.fetch("models")
                      .reject { |model| predefined_model?(ruby_model_name(model.fetch("javaName"))) }
                      .sort_by { |model| ruby_model_name(model.fetch("javaName")) }

      models.map { |model| format_model(model) }.join("\n")
    end

    private

    def validate_schema!
      schema_version = @schema.fetch("schemaVersion")
      return if SUPPORTED_SCHEMA_VERSIONS.include?(schema_version)

      raise ArgumentError,
            "Unsupported schemaVersion: #{schema_version.inspect}; " \
              "supported versions: #{SUPPORTED_SCHEMA_VERSIONS.inspect}"
    end

    def validate_generated_name_uniqueness!
      generated_models = @schema
                           .fetch("models")
                           .reject do |model|
        generated_name = ruby_model_name(
          model.fetch("javaName")
        )

        predefined_model?(generated_name)
      end

      grouped = generated_models.group_by do |model|
        ruby_model_name(
          model.fetch("javaName")
        )
      end

      duplicates = grouped.select do |_name, models|
        models.length > 1
      end

      return if duplicates.empty?

      details = duplicates.map do |name, models|
        java_names = models.map do |model|
          model.fetch("javaName")
        end

        "#{name}: #{java_names.join(', ')}"
      end

      raise ArgumentError,
            "Duplicate generated Ruby model names:\n" \
              "#{details.join("\n")}"
    end

    def predefined_model?(name)
      PREDEFINED_MODELS.include?(name) || PREDEFINED_SIMPLE_CLASSES.include?(name)
    end

    def format_model(model)
      name = ruby_model_name(model.fetch("javaName"))
      validate_ruby_constant_name!(name, model.fetch("javaName"))

      properties = properties_for(model)
      members = properties.map do |property|
        ":#{ruby_property_name(property.fetch("jsonName"))}"
      end

      lines = []
      lines << "  class << #{name} ="
      lines << if members.empty?
                 "    Base.new()"
               else
                 "    Base.new(#{members.join(', ')})"
               end
      lines << "    def decode(hash)"
      lines << "      unless hash.is_a?(Hash)"
      lines << %q(        raise TypeError, "Can't convert #{hash.class} to Hash")
      lines << "      end"
      lines << "      obj = allocate"
      lines << "      obj.send(:initialize_struct,"

      properties.each do |property|
        json_name = property.fetch("jsonName")
        source_expression = "hash[#{json_name.dump}]"
        decoded_expression = decode_expression(property.fetch("type"), source_expression)
        lines << "        #{decoded_expression},"
      end

      lines << "      )"
      lines << "      obj"
      lines << "    end"
      lines << "  end"
      lines << ""
      lines.join("\n")
    end

    def properties_for(model)
      properties = model
                     .fetch("properties")
                     .map(&:dup)

      trino_version = @schema.fetch(
        "trinoVersion"
      )

      java_name = model.fetch(
        "javaName"
      )

      version_overrides =
        LEGACY_EXTRA_PROPERTIES.fetch(
          trino_version,
          {}
        )

      extras = version_overrides.fetch(
        java_name,
        []
      )

      existing_names = properties.map do |property|
        property.fetch("jsonName")
      end

      extras.each do |property|
        json_name = property.fetch(
          "jsonName"
        )

        next if existing_names.include?(
          json_name
        )

        properties << property
        existing_names << json_name
      end

      properties
    end

    def decode_expression(type, expression)
      kind = type.fetch("kind")

      case kind
      when "primitive", "opaque"
        expression
      when "enum"
        nil_guard(expression, "#{expression}.downcase.to_sym")
      when "model"
        model_name = ruby_model_name(type.fetch("name"))
        nil_guard(expression, "#{model_name}.decode(#{expression})")
      when "value"
        decode_value_type(type, expression)
      when "optional"
        decode_expression(type.fetch("elementType"), expression)
      when "list", "set", "array"
        decode_array_type(type, expression)
      when "map"
        decode_map_type(type, expression)
      else
        raise ArgumentError, "Unsupported schema type: #{kind.inspect}"
      end
    end

    def decode_value_type(type, expression)
      java_name = type.fetch("name")
      wire_expression = decode_expression(type.fetch("elementType"), expression)
      wrapper = VALUE_WRAPPERS[java_name]

      return wire_expression if wrapper.nil?

      nil_guard(expression, "#{wrapper}.new(#{wire_expression})")
    end

    def decode_array_type(type, expression)
      element_expression = decode_expression(type.fetch("elementType"), "element")
      decoded = "#{expression}.map { |element| #{element_expression} }"
      nil_guard(expression, decoded)
    end

    def decode_map_type(type, expression)
      key_expression = decode_expression(type.fetch("keyType"), "key")
      value_expression = decode_expression(type.fetch("valueType"), "map_value")
      decoded = "Hash[#{expression}.to_a.map { |key, map_value| " \
        "[#{key_expression}, #{value_expression}] }]"
      nil_guard(expression, decoded)
    end

    def nil_guard(expression, decoded_expression)
      "(#{expression}.nil? ? nil : #{decoded_expression})"
    end

    def ruby_model_name(java_name)
      aliased_name = MODEL_ALIASES[java_name]
      return aliased_name unless aliased_name.nil?

      model = @models_by_java_name[java_name]
      return model.fetch("simpleName") unless model.nil?

      java_name.split(".").last.split("$").last
    end

    def validate_ruby_constant_name!(name, java_name)
      return if name.match?(/\A[A-Z][A-Za-z0-9_]*\z/)

      raise ArgumentError,
            "Invalid generated Ruby constant #{name.inspect} for #{java_name.inspect}"
    end

    def ruby_property_name(json_name)
      name = json_name.gsub(/[A-Z]/) do |character|
        "_#{character.downcase}"
      end

      unless name.match?(/\A[a-z_][A-Za-z0-9_]*\z/)
        raise ArgumentError,
              "Invalid generated Ruby member #{name.inspect} from JSON property #{json_name.inspect}"
      end

      name
    end
  end
end
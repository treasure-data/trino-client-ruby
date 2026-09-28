module TrinoModels
  require "find"
  require "stringio"

  PRIMITIVE_TYPES = %w[
    String
    boolean
    long
    int
    short
    byte
    double
    float
    Integer
    Double
    Boolean
  ]

  ARRAY_PRIMITIVE_TYPES = PRIMITIVE_TYPES.map { |type| "#{type}[]" }

  class Model < Struct.new(:name, :fields)
  end

  class Field < Struct.new(
    :key,
    :nullable,
    :array,
    :map,
    :type,
    :base_type,
    :map_value_base_type,
    :base_type_alias
  )
    alias_method :nullable?, :nullable
    alias_method :array?, :array
    alias_method :map?, :map

    def name
      @name ||= key.gsub(/[A-Z]/) { |field| "_#{field.downcase}" }
    end
  end

  class ModelAnalysisError < StandardError
  end

  class ModelAnalyzer
    CREATOR_PATTERN = /
      @JsonCreator
      (?:\([^)]*\))?
      \s+
      (?:@\w+(?:\([^)]*\))?\s+)*
      public
      \s+
      (?:static\s+)?
      (\w+)
      [\w\s]*
      \(
    /x

    RECORD_PATTERN = /
      \brecord
      \s+
      (\w+)
      \s*
      \(
    /x

    ANNOTATION_PATTERN = /@\w+(?:\([^)]*\))?\s*/
    JSON_PROPERTY_PATTERN = /@JsonProperty\("(\w+)"\)/
    GENERIC_PATTERN = /(\w+)<(\w+)>/

    def initialize(source_path, options = {})
      @source_path = source_path
      @ignore_types =
        PRIMITIVE_TYPES +
        ARRAY_PRIMITIVE_TYPES +
        (options[:skip_models] || [])
      @path_mapping = options[:path_mapping] || {}
      @name_mapping = options[:name_mapping] || {}
      @extra_fields = options[:extra_fields] || {}
      @models = {}
      @skipped_models = []
    end

    attr_reader :skipped_models

    def models
      @models.values.sort_by { |model| model.name }
    end

    def analyze(root_models)
      root_models.each do |model_name|
        analyze_model(model_name)
      end
    end

    private

    def analyze_fields(model_name, raw_fields, generic: nil)
      model_name = "#{model_name}_#{generic}" if generic
      extra = @extra_fields[model_name] || []

      fields = raw_fields
                 .concat(extra)
                 .uniq { |key, _nullable, _type| key }
                 .map do |key, nullable, type|
        build_field(model_name, key, nullable, type, generic)
      end

      @models[model_name] = Model.new(model_name, fields)

      fields.each do |field|
        analyze_model(field.base_type, model_name)

        if field.map_value_base_type
          analyze_model(field.map_value_base_type, model_name)
        end
      end

      fields
    end

    def build_field(model_name, key, nullable, type, generic)
      map = false
      array = false
      nullable = !!nullable
      map_value_base_type = nil
      base_type_alias = nil

      if match = /\A(?:List|Set|Collection)<(\w+)>\z/.match(type)
        base_type = match[1]
        array = true
      elsif match = /\A(?:Map|ListMultimap)<(\w+),\s*(\w+)>\z/.match(type)
        base_type = match[1]
        map_value_base_type = match[2]
        map = true
      elsif match = /\AOptional<([\w\[\]<>]+)>\z/.match(type)
        base_type = match[1]
        nullable = true
      elsif type == "OptionalInt"
        base_type = "Integer"
        nullable = true
      elsif type == "OptionalLong"
        base_type = "Long"
        nullable = true
      elsif type == "OptionalDouble"
        base_type = "Double"
        nullable = true
      elsif type.match?(/\w+/)
        base_type = type
      else
        raise ModelAnalysisError,
              "Unsupported type #{type} in model #{model_name}"
      end

      base_type =
        @name_mapping[[model_name, base_type]] ||
        base_type

      map_value_base_type =
        @name_mapping[[model_name, map_value_base_type]] ||
        map_value_base_type

      if generic
        base_type = generic if base_type == "T"

        if map_value_base_type == "T"
          map_value_base_type = generic
        end
      end

      if match = GENERIC_PATTERN.match(base_type)
        base_type_alias = "#{match[1]}_#{match[2]}"
      end

      Field.new(
        key,
        nullable,
        array,
        map,
        type,
        base_type,
        map_value_base_type,
        base_type_alias
      )
    end

    def analyze_model(model_name, parent_model = nil, generic: nil)
      return if @models[model_name] || @ignore_types.include?(model_name)

      if match = GENERIC_PATTERN.match(model_name)
        analyze_model(match[1], generic: match[2])
        analyze_model(match[2])
        return
      end

      path = find_class_file(model_name, parent_model)
      java = File.read(path)

      declarations = find_declarations(java)
      source_model_name = File.basename(path, ".java")

      declaration = declarations.find do |name, _parameters|
        name == model_name || name == source_model_name
      end

      unless declaration
        raise ModelAnalysisError,
              "Can't find JsonCreator or record declaration of a model class " \
                "#{model_name} of #{parent_model} at #{path}"
      end

      declarations.each do |inner_model_name, parameters|
        next if inner_model_name == model_name
        next if inner_model_name == source_model_name
        next if @models[inner_model_name]
        next if @ignore_types.include?(inner_model_name)

        analyze_fields(
          inner_model_name,
          parse_parameters(parameters)
        )
      end

      _, parameters = declaration

      analyze_fields(
        model_name,
        parse_parameters(parameters),
        generic: generic
      )
    rescue => error
      puts "Skipping model #{parent_model}/#{model_name}: #{error}"
      @skipped_models << model_name
    end

    def find_declarations(java)
      find_declarations_by_pattern(java, CREATOR_PATTERN) +
        find_declarations_by_pattern(java, RECORD_PATTERN)
    end

    def find_declarations_by_pattern(java, pattern)
      declarations = []
      offset = 0

      while match = pattern.match(java, offset)
        opening_parenthesis = match.end(0) - 1
        parameters, closing_parenthesis =
          extract_parenthesized(java, opening_parenthesis)

        declarations << [match[1], parameters]
        offset = closing_parenthesis + 1
      end

      declarations
    end

    def extract_parenthesized(source, opening_parenthesis)
      depth = 0

      source.each_char.with_index do |character, index|
        next if index < opening_parenthesis

        case character
        when "("
          depth += 1
        when ")"
          depth -= 1

          if depth.zero?
            return [
              source[(opening_parenthesis + 1)...index],
              index
            ]
          end
        end
      end

      raise ModelAnalysisError, "Unclosed parameter list"
    end

    def parse_parameters(parameters)
      parameters = remove_comments(parameters)

      split_parameters(parameters).map do |parameter|
        parse_parameter(parameter)
      end
    end

    def remove_comments(source)
      source
        .gsub(%r{/\*.*?\*/}m, "")
        .gsub(%r{//.*$}, "")
    end

    def split_parameters(parameters)
      result = []
      current = +""
      angle_depth = 0
      parenthesis_depth = 0
      bracket_depth = 0

      parameters.each_char do |character|
        case character
        when "<"
          angle_depth += 1
          current << character
        when ">"
          angle_depth -= 1
          current << character
        when "("
          parenthesis_depth += 1
          current << character
        when ")"
          parenthesis_depth -= 1
          current << character
        when "["
          bracket_depth += 1
          current << character
        when "]"
          bracket_depth -= 1
          current << character
        when ","
          if angle_depth.zero? &&
             parenthesis_depth.zero? &&
             bracket_depth.zero?
            result << current.strip
            current = +""
          else
            current << character
          end
        else
          current << character
        end
      end

      result << current.strip unless current.strip.empty?
      result
    end

    def parse_parameter(parameter)
      json_property = parameter[JSON_PROPERTY_PATTERN, 1]
      nullable = parameter.match?(/@Nullable\b/)

      declaration = parameter
                      .gsub(ANNOTATION_PATTERN, "")
                      .sub(/\Afinal\s+/, "")
                      .strip

      match = /\A(.+?)\s+(\w+)\z/.match(declaration)

      unless match
        raise ModelAnalysisError,
              "Unsupported parameter #{parameter.strip}"
      end

      type = normalize_type(match[1].strip)
      parameter_name = match[2]
      key = json_property || parameter_name

      [key, nullable ? "@Nullable " : nil, type]
    end

    def normalize_type(type)
      normalized = type.gsub(
        /(?:[a-z_]\w*\.)+([A-Z]\w*)/
      ) { Regexp.last_match(1) }

      normalized = normalized.gsub(
        /\b[A-Z]\w*\.([A-Z]\w*)/
      ) { Regexp.last_match(1) }

      normalized.gsub(/\?\s+extends\s+/, "")
    end

    def find_class_file(model_name, parent_model)
      return @path_mapping[model_name] if @path_mapping.key?(model_name)

      @source_files ||= Find.find(@source_path).to_a
      pattern = /\/#{Regexp.escape(model_name)}\.java$/

      matched = @source_files.find_all do |path|
        path.match?(pattern) &&
          !path.include?("/test/") &&
          !path.include?("/verifier/")
      end

      if matched.empty?
        raise ModelAnalysisError,
              "Model class #{model_name} is not found"
      end

      if matched.size == 1
        matched.first
      else
        raise ModelAnalysisError,
              "Model class #{model_name} of #{parent_model} " \
                "found multiple match #{matched}"
      end
    end
  end

  class ModelFormatter
    def initialize(options = {})
      @indent = options[:indent] || " "
      @base_indent_count = options[:base_indent_count] || 0
      @struct_class = options[:struct_class] || "Struct"
      @special_struct_initialize_method =
        options[:special_struct_initialize_method]
      @primitive_types =
        PRIMITIVE_TYPES +
        ARRAY_PRIMITIVE_TYPES +
        (options[:primitive_types] || [])
      @skip_types = options[:skip_types] || []
      @simple_classes = options[:simple_classes]
      @enum_types = options[:enum_types]
      @special_types = options[:special_types] || {}
      @data = StringIO.new
    end

    def contents
      @data.string
    end

    def format(models)
      @models = models

      models.each do |model|
        @model = model

        puts_with_indent 0, "class << #{model.name} ="
        puts_with_indent(
          2,
          "#{@struct_class}.new(" \
            "#{model.fields.map { |field| ":#{field.name}" }.join(", ")})"
        )
        format_decode
        puts_with_indent 0, "end"
        line
      end
    end

    private

    def line
      @data.puts ""
    end

    def puts_with_indent(count, string)
      @data.puts(
        "#{@indent * (@base_indent_count + count)}#{string}"
      )
    end

    def format_decode
      puts_with_indent 1, "def decode(hash)"

      puts_with_indent 2, "unless hash.is_a?(Hash)"
      puts_with_indent(
        3,
        'raise TypeError, "Can\'t convert #{hash.class} to Hash"'
      )
      puts_with_indent 2, "end"

      if @special_struct_initialize_method
        puts_with_indent 2, "obj = allocate"
        puts_with_indent(
          2,
          "obj.send(:#{@special_struct_initialize_method},"
        )
      else
        puts_with_indent 2, "new("
      end

      @model.fields.each do |field|
        next if @skip_types.include?(field.base_type)
        next if @skip_types.include?(field.map_value_base_type)

        expression = format_field_expression(field)
        puts_with_indent 3, "#{expression},"
      end

      puts_with_indent 2, ")"

      if @special_struct_initialize_method
        puts_with_indent 2, "obj"
      end

      puts_with_indent 1, "end"
    end

    def format_field_expression(field)
      if @primitive_types.include?(field.base_type) && !field.map?
        return "hash[\"#{field.key}\"]"
      end

      expression = +""
      expression << "hash[\"#{field.key}\"] && "

      if field.map?
        format_map_expression(field, expression)
      elsif field.array?
        element_expression = convert_expression(
          field.base_type,
          field.base_type,
          "h"
        )

        expression <<
          "hash[\"#{field.key}\"].map " \
            "{|h| #{element_expression} }"
      else
        expression << convert_expression(
          field.type,
          field.base_type_alias || field.base_type,
          "hash[\"#{field.key}\"]"
        )
      end

      expression
    end

    def format_map_expression(field, expression)
      key_expression = convert_expression(
        field.base_type,
        field.base_type,
        "k"
      )

      value_expression = convert_expression(
        field.map_value_base_type,
        field.map_value_base_type,
        "v"
      )

      if key_expression == "k" && value_expression == "v"
        "hash[\"#{field.key}\"]"
      else
        expression +
          "Hash[hash[\"#{field.key}\"].to_a.map! " \
            "{|k,v| [#{key_expression}, #{value_expression}] }]"
      end
    end

    def convert_expression(type, base_type, key)
      if @special_types[type]
        @special_types[type].call(key)
      elsif @enum_types.include?(type) ||
            @enum_types.include?(base_type)
        "#{key}.downcase.to_sym"
      elsif @primitive_types.include?(base_type)
        key
      elsif @simple_classes.include?(base_type)
        "#{base_type}.new(#{key})"
      else
        "#{base_type}.decode(#{key})"
      end
    end
  end
end

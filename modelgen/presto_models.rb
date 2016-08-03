
module PrestoModels
  require 'find'
  require 'stringio'

  PRIMITIVE_TYPES = %w[String boolean long int short byte double float Integer]

  class Model < Struct.new(:name, :fields)
  end

  class Field < Struct.new(:key, :nullable, :array, :map, :type, :base_type, :map_value_base_type)
    alias_method :nullable?, :nullable
    alias_method :array?, :array
    alias_method :map?, :map

    def name
      @name ||= key.gsub(/[A-Z]/) {|f| "_#{f.downcase}" }
    end
  end

  class ModelAnalysisError < StandardError
  end

  class ModelAnalyzer
    def initialize(source_path, options={})
      @source_path = source_path
      @ignore_types = PRIMITIVE_TYPES + (options[:skip_models] || [])
      @path_mapping = options[:path_mapping] || {}
      @name_mapping = options[:name_mapping] || {}
      @models = {}
      @skipped_models = []
    end

    attr_reader :skipped_models

    def models
      @models.values.sort_by {|model| model.name }
    end

    def analyze(root_models)
      root_models.each {|model_name|
        analyze_model(model_name)
      }
    end

    private

    PROPERTY_PATTERN = /@JsonProperty\(\"(\w+)\"\)\s+(@Nullable\s+)?([\w\<\>\,\s]+)\s+(\w+)/
    CREATOR_PATTERN = /@JsonCreator[\w\s]+\((?:\s*#{PROPERTY_PATTERN}\s*,?)+\)/

    def analyze_model(model_name, parent_model = nil)
      return if @models[model_name] || @ignore_types.include?(model_name)

      path = find_class_file(model_name, parent_model)
      java = File.read(path)

      m = CREATOR_PATTERN.match(java)
      unless m
        raise ModelAnalysisError, "Can't find JsonCreator of a model class #{model_name} of #{parent_model} at #{path}"
      end

      fields = m[0].scan(PROPERTY_PATTERN).map do |key,nullable,type,field|
        map = false
        array = false
        nullable = !!nullable
        if m = /(?:List|Set)<(\w+)>/.match(type)
          base_type = m[1]
          array = true
        elsif m = /(?:Map|ListMultimap)<(\w+),\s*(\w+)>/.match(type)
          base_type = m[1]
          map_value_base_type = m[2]
          map = true
        elsif m = /Optional<(\w+)>/.match(type)
          base_type = m[1]
          nullable = true
        elsif m = /OptionalInt/.match(type)
          base_type = 'Integer'
          nullable = true
        elsif type =~ /\w+/
          base_type = type
        else
          raise ModelAnalysisError, "Unsupported type #{type} in model #{model_name}"
        end
        base_type = @name_mapping[[model_name, base_type]] || base_type
        map_value_base_type = @name_mapping[[model_name, map_value_base_type]] || map_value_base_type
        Field.new(key, !!nullable, array, map, type, base_type, map_value_base_type)
      end

      @models[model_name] = Model.new(model_name, fields)

      # recursive call
      fields.each do |field|
        analyze_model(field.base_type, model_name)
        analyze_model(field.map_value_base_type, model_name) if field.map_value_base_type
      end

    rescue => e
      puts "Skipping model #{parent_model}/#{model_name}: #{e}"
      @skipped_models << model_name
    end

    def find_class_file(model_name, parent_model)
      return @path_mapping[model_name] if @path_mapping.has_key? model_name

      @source_files ||= Find.find(@source_path).to_a
      pattern = /\/#{model_name}.java$/
      matched = @source_files.find_all {|path| path =~ pattern }
      if matched.empty?
        raise ModelAnalysisError, "Model class #{model_name} is not found"
      end
      if matched.size == 1
        return matched.first
      else
        raise ModelAnalysisError, "Model class #{model_name} of #{parent_model} found multiple match #{matched}"
      end
    end
  end

  class ModelFormatter
    def initialize(options={})
      @indent = options[:indent] || '  '
      @base_indent_count = options[:base_indent_count] || 0
      @struct_class = options[:struct_class] || 'Struct'
      @special_struct_initialize_method = options[:special_struct_initialize_method]
      @primitive_types = PRIMITIVE_TYPES + (options[:primitive_types] || [])
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
        puts_with_indent 2, "#{@struct_class}.new(#{model.fields.map {|f| ":#{f.name}" }.join(', ')})"
        format_decode
        puts_with_indent 0, "end"
        line
      end
    end

    private

    def line
      @data.puts ""
    end

    def puts_with_indent(n, str)
      @data.puts "#{@indent * (@base_indent_count + n)}#{str}"
    end

    def format_decode
      puts_with_indent 1, "def decode(hash)"

      puts_with_indent 2, "unless hash.is_a?(Hash)"
      puts_with_indent 3, "raise TypeError, \"Can't convert \#{hash.class} to Hash\""
      puts_with_indent 2, "end"

      if @special_struct_initialize_method
        puts_with_indent 2, "obj = allocate"
        puts_with_indent 2, "obj.send(:#{@special_struct_initialize_method},"
      else
        puts_with_indent 2, "new("
      end

      @model.fields.each do |field|
        next if @skip_types.include?(field.base_type) || @skip_types.include?(field.map_value_base_type)

        if @primitive_types.include?(field.base_type) && !field.map?
          expr = "hash[\"#{field.key}\"]"
        else
          expr = ""
          expr << "hash[\"#{field.key}\"] && " #if field.nullable?

          if field.map?
            key_expr = convert_expression(field.base_type, field.base_type, "k")
            value_expr = convert_expression(field.map_value_base_type, field.map_value_base_type, "v")
            if key_expr == 'k' && value_expr == 'v'
              expr = "hash[\"#{field.key}\"]"
            else
              expr << "Hash[hash[\"#{field.key}\"].to_a.map! {|k,v| [#{key_expr}, #{value_expr}] }]"
            end
          elsif field.array?
            elem_expr = convert_expression(field.base_type, field.base_type, "h")
            expr << "hash[\"#{field.key}\"].map {|h| #{elem_expr} }"
          else
            expr << convert_expression(field.type, field.base_type, "hash[\"#{field.key}\"]")
          end
        end

        #comment = "# #{field.base_type}#{field.array? ? '[]' : ''} #{field.key}"
        #puts_with_indent 3, "#{expr},  #{comment}"
        puts_with_indent 3, "#{expr},"
      end

      puts_with_indent 2, ")"

      if @special_struct_initialize_method
        puts_with_indent 2, "obj"
      end

      puts_with_indent 1, "end"
    end

    def convert_expression(type, base_type, key)
      if @special_types[type]
        special.call(key)
      elsif @enum_types.include?(type)
        "#{key}.downcase.to_sym"
      elsif @primitive_types.include?(base_type)
        key
      elsif @simple_classes.include?(base_type)
        "#{base_type}.new(#{key})"
      else  # model class
        "#{base_type}.decode(#{key})"
      end
    end
  end
end


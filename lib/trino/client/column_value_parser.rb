module Trino::Client
  class ColumnValueParser
    INSIDE_MATCHING_PARENS_REGEX = /\((?>[^)(]+|\g<0>)*\)/

    attr_reader :name, :type, :scalar_parser

    def initialize(column, scalar_parser = nil)
      @name = column.name
      @type = prepare_type_for_parsing(column.type)
      @scalar_parser = scalar_parser
    end

    # Public: Parse the value of a row's field by using its column's Trino type.
    # Trino types can be scalars like VARCHAR and TIMESTAMP or complex types
    # like ARRAY and ROW. ROW types are treated as objects.
    # An ARRAY column's type is an array of types as you'd expect. A ROW
    # column's type is a comma-separated list of space-separated (name, type) tuples.
    #
    # data - The value of a row's field. Can be a string, number, an array of those,
    #        or an arrays of arrays, etc.
    # dtype - The Trino type string of the column. See above explanation.
    #
    # Returns:
    # - The given value for strings and numbers
    # - A Time for timestamps
    # - A Hash of { field1 => value1, field2 => value2, ...etc } for row types
    # - An array of the above for array types
    def value(data, dtype = type)
      # Convert Trino ARRAY elements into Ruby Arrays
      if starts_with?(dtype, 'array(')
        return parse_array_element(data, dtype)

      # Convert Trino ROW elements into Ruby Hashes
      elsif starts_with?(dtype, 'row(')
        return parse_row_element(data, dtype)

      # If defined, use scalar_parser to convert scalar types
      elsif !scalar_parser.nil?
        return scalar_parser.call(data, dtype)
      end

      # Otherwise, values are returned unaltered
      data
    end

    private

    # Private: Remove quotation marks and handle recent versions of
    # Trino having a 'with time zone' suffix on some fields that breaks
    # out assumption that types don't have spaces in them.
    #
    # Returns a string.
    def prepare_type_for_parsing(type)
      type.gsub('"', '').gsub(' with time zone', '_with_time_zone')
    end

    def parse_array_element(data, dtype)
      # If the element is empty, return an empty array
      return [] if blank?(data)

      # Inner data type will be the current dtype with `array(` and `)` chopped off
      inner_dtype = dtype.match(INSIDE_MATCHING_PARENS_REGEX)[0][1..-2]

      data.map { |inner_data| value(inner_data, inner_dtype) }
    end

    def parse_row_element(data, dtype)
      # If the element is empty, return an empty object
      return {} if blank?(data)

      parsed_row_element = {}

      inner_dtype = dtype.match(INSIDE_MATCHING_PARENS_REGEX)[0][1..-2]
      elems = inner_dtype.split(' ')
      num_elems_to_skip = 0
      field_position = 0

      # Iterate over each datatype of the row and mutate parsed_row_element
      # to have a key of the field name and value for that field's value.
      elems.each_with_index do |field, i|
        # We detected an array or row and are skipping all of the elements within it
        # since its conversion was handled by calling `value` recursively.
        if num_elems_to_skip.positive?
          num_elems_to_skip -= 1
          next
        end

        # Field names never have these characters and are never the last element.
        next if field.include?(',') || field.include?('(') || field.include?(')') || i == elems.length - 1

        type = elems[(i + 1)..].join(' ')

        # If this row has a nested array or row, the type of this field is that array or row's type.
        if starts_with?(type, 'array(') || starts_with?(type, 'row(')
          datatype = type.sub(/\(.*/, '')
          type = "#{datatype}#{type.match(INSIDE_MATCHING_PARENS_REGEX)[0]}"
          num_elems_to_skip = type.split(' ').length # see above comment about num_elems_to_skip
        end

        parsed_row_element[field] = value(data[field_position], type)
        field_position += 1
      end

      parsed_row_element
    end

    def blank?(obj)
      obj.respond_to?(:empty?) ? !!obj.empty? : !obj
    end

    def starts_with?(str, prefix)
      prefix.respond_to?(:to_str) && str[0, prefix.length] == prefix
    end
  end
end

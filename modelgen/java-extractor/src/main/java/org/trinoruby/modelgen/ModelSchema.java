package org.trinoruby.modelgen;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.util.List;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record ModelSchema(
        int schemaVersion,
        String trinoVersion,
        List<String> roots,
        List<ModelDefinition> models)
{
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record ModelDefinition(
            String javaName,
            String simpleName,
            String kind,
            List<PropertyDefinition> properties)
    {
    }

    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record PropertyDefinition(
            String jsonName,
            String javaName,
            Integer creatorIndex,
            String nullability,
            TypeDefinition type)
    {
    }

    /**
     * kind:
     *
     * primitive
     * opaque
     * enum
     * model
     * value
     * optional
     * list
     * set
     * array
     * map
     */
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public record TypeDefinition(
            String kind,
            String name,
            TypeDefinition elementType,
            TypeDefinition keyType,
            TypeDefinition valueType,
            List<String> enumValues)
    {
        public static TypeDefinition primitive(String name)
        {
            return new TypeDefinition(
                    "primitive",
                    name,
                    null,
                    null,
                    null,
                    null);
        }

        public static TypeDefinition opaque(String name)
        {
            return new TypeDefinition(
                    "opaque",
                    name,
                    null,
                    null,
                    null,
                    null);
        }

        public static TypeDefinition model(String name)
        {
            return new TypeDefinition(
                    "model",
                    name,
                    null,
                    null,
                    null,
                    null);
        }

        public static TypeDefinition enumType(
                String name,
                List<String> values)
        {
            return new TypeDefinition(
                    "enum",
                    name,
                    null,
                    null,
                    null,
                    List.copyOf(values));
        }

        public static TypeDefinition optional(
                TypeDefinition elementType)
        {
            return new TypeDefinition(
                    "optional",
                    null,
                    elementType,
                    null,
                    null,
                    null);
        }

        public static TypeDefinition list(
                TypeDefinition elementType)
        {
            return new TypeDefinition(
                    "list",
                    null,
                    elementType,
                    null,
                    null,
                    null);
        }

        public static TypeDefinition set(
                TypeDefinition elementType)
        {
            return new TypeDefinition(
                    "set",
                    null,
                    elementType,
                    null,
                    null,
                    null);
        }

        public static TypeDefinition array(
                TypeDefinition elementType)
        {
            return new TypeDefinition(
                    "array",
                    null,
                    elementType,
                    null,
                    null,
                    null);
        }

        public static TypeDefinition map(
                TypeDefinition keyType,
                TypeDefinition valueType)
        {
            return new TypeDefinition(
                    "map",
                    null,
                    null,
                    keyType,
                    valueType,
                    null);
        }

        public static TypeDefinition value(
                String name,
                TypeDefinition valueType)
        {
            return new TypeDefinition(
                    "value",
                    name,
                    valueType,
                    null,
                    null,
                    null);
        }
    }
}
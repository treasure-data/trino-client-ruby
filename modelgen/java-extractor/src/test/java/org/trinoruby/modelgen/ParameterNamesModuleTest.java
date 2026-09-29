package org.trinoruby.modelgen;

import com.fasterxml.jackson.databind.BeanDescription;
import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.introspect.BeanPropertyDefinition;
import io.trino.spi.eventlistener.TableInfo;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ParameterNamesModuleTest
{
    private final ObjectMapper objectMapper =
            ModelExtractor.createObjectMapper();

    @Test
    void recognizesTableInfoConstructorProperties()
    {
        JavaType type =
                objectMapper
                        .getTypeFactory()
                        .constructType(
                                TableInfo.class);

        BeanDescription description =
                objectMapper
                        .getDeserializationConfig()
                        .introspect(type);

        List<BeanPropertyDefinition> constructorProperties =
                description.findProperties().stream()
                        .filter(property ->
                                property
                                        .getConstructorParameter()
                                        != null)
                        .toList();

        Set<String> propertyNames =
                constructorProperties.stream()
                        .map(
                                BeanPropertyDefinition::getName)
                        .collect(
                                Collectors.toSet());

        assertEquals(
                Set.of(
                        "catalog",
                        "schema",
                        "table",
                        "authorization",
                        "filters",
                        "columns",
                        "directlyReferenced",
                        "viewText",
                        "referenceChain"),
                propertyNames);
    }
}

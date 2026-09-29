package org.trinoruby.modelgen;

import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.opentelemetry.api.trace.Span;
import io.trino.client.QueryData;
import io.trino.spi.resourcegroups.ResourceGroupId;
import io.trino.transaction.TransactionId;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class TypeClassifierTest
{
    private final ObjectMapper objectMapper =
            ModelExtractor.createObjectMapper();

    private final TypeClassifier classifier =
            new TypeClassifier(
                    Set.of(),
                    objectMapper.getTypeFactory());

    @Test
    void classifiesOptionalString()
    {
        JavaType type =
                objectMapper
                        .getTypeFactory()
                        .constructParametricType(
                                Optional.class,
                                String.class);

        TypeClassifier.Classification result =
                classifier.classify(type);

        assertEquals(
                "optional",
                result.type().kind());

        assertEquals(
                "primitive",
                result.type()
                        .elementType()
                        .kind());

        assertEquals(
                String.class.getName(),
                result.type()
                        .elementType()
                        .name());

        assertTrue(
                result.referencedModels().isEmpty());
    }

    @Test
    void classifiesTransactionIdUsingJsonValue()
    {
        JavaType type =
                objectMapper
                        .getTypeFactory()
                        .constructType(
                                TransactionId.class);

        TypeClassifier.Classification result =
                classifier.classify(type);

        assertEquals(
                "primitive",
                result.type().kind());

        assertEquals(
                String.class.getName(),
                result.type().name());

        assertTrue(
                result.referencedModels().isEmpty());
    }

    @Test
    void classifiesResourceGroupIdUsingJsonValue()
    {
        JavaType type =
                objectMapper
                        .getTypeFactory()
                        .constructType(
                                ResourceGroupId.class);

        TypeClassifier.Classification result =
                classifier.classify(type);

        assertEquals(
                "list",
                result.type().kind());

        assertEquals(
                "primitive",
                result.type()
                        .elementType()
                        .kind());

        assertEquals(
                String.class.getName(),
                result.type()
                        .elementType()
                        .name());

        assertTrue(
                result.referencedModels().isEmpty());
    }

    @Test
    void classifiesQueryDataAsOpaque()
    {
        JavaType type =
                objectMapper
                        .getTypeFactory()
                        .constructType(
                                QueryData.class);

        TypeClassifier.Classification result =
                classifier.classify(type);

        assertEquals(
                "opaque",
                result.type().kind());

        assertEquals(
                QueryData.class.getName(),
                result.type().name());

        assertTrue(
                result.referencedModels().isEmpty());
    }

    @Test
    void classifiesSpanAsOpaque()
    {
        JavaType type =
                objectMapper
                        .getTypeFactory()
                        .constructType(
                                Span.class);

        TypeClassifier.Classification result =
                classifier.classify(type);

        assertEquals(
                "opaque",
                result.type().kind());

        assertEquals(
                Span.class.getName(),
                result.type().name());

        assertTrue(
                result.referencedModels().isEmpty());
    }
}
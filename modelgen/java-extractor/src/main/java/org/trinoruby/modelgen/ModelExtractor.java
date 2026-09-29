package org.trinoruby.modelgen;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.BeanDescription;
import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.introspect.AnnotatedMember;
import com.fasterxml.jackson.databind.introspect.AnnotatedParameter;
import com.fasterxml.jackson.databind.introspect.BeanPropertyDefinition;
import com.fasterxml.jackson.datatype.jdk8.Jdk8Module;
import com.fasterxml.jackson.module.paramnames.ParameterNamesModule;

import java.io.IOException;
import java.lang.annotation.Annotation;
import java.lang.reflect.Modifier;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Set;

import static org.trinoruby.modelgen.ModelSchema.ModelDefinition;
import static org.trinoruby.modelgen.ModelSchema.PropertyDefinition;

public final class ModelExtractor
{
    private final ObjectMapper objectMapper;
    private final TypeClassifier typeClassifier;

    private ModelExtractor(
            ObjectMapper objectMapper,
            TypeClassifier typeClassifier)
    {
        this.objectMapper = objectMapper;
        this.typeClassifier = typeClassifier;
    }

    static void main(String[] args)
            throws Exception
    {
        Arguments arguments =
                Arguments.parse(args);

        List<String> roots =
                readConfigLines(arguments.roots());

        ObjectMapper objectMapper =
                createObjectMapper();

        ModelExtractor extractor =
                new ModelExtractor(
                        objectMapper,
                        new TypeClassifier(
                                objectMapper.getTypeFactory()));

        ModelSchema schema =
                extractor.extract(
                        arguments.trinoVersion(),
                        roots);

        Path output = arguments.output();

        if (output.getParent() != null) {
            Files.createDirectories(
                    output.getParent());
        }

        objectMapper
                .writerWithDefaultPrettyPrinter()
                .writeValue(
                        output.toFile(),
                        schema);

        System.out.printf(
                "Generated %s with %d models.%n",
                output,
                schema.models().size());
    }

    static ObjectMapper createObjectMapper()
    {
        return new ObjectMapper()
                .registerModule(new Jdk8Module())
                .registerModule(
                        new ParameterNamesModule())
                .setSerializationInclusion(
                        JsonInclude.Include.NON_NULL);
    }

    private ModelSchema extract(
            String trinoVersion,
            List<String> rootClassNames)
            throws ClassNotFoundException
    {
        Queue<Class<?>> pending =
                new ArrayDeque<>();

        Set<String> enqueued =
                new HashSet<>();

        for (String rootClassName :
                rootClassNames) {
            Class<?> rootClass =
                    Class.forName(
                            rootClassName,
                            false,
                            Thread.currentThread()
                                    .getContextClassLoader());

            pending.add(rootClass);
            enqueued.add(rootClass.getName());
        }

        Map<String, ModelDefinition> models =
                new LinkedHashMap<>();

        while (!pending.isEmpty()) {
            Class<?> modelClass =
                    pending.remove();

            if (models.containsKey(
                    modelClass.getName())) {
                continue;
            }

            System.err.println(
                    "Extracting model: "
                            + modelClass.getName());

            ExtractedModel extracted =
                    extractModel(modelClass);

            models.put(
                    modelClass.getName(),
                    extracted.definition());

            List<Class<?>> referencedModels =
                    extracted.referencedModels().stream()
                            .sorted(
                                    Comparator.comparing(
                                            Class::getName))
                            .toList();

            for (Class<?> referencedModel :
                    referencedModels) {
                if (enqueued.add(
                        referencedModel.getName())) {
                    pending.add(referencedModel);
                }
            }
        }

        List<ModelDefinition> sortedModels =
                models.values().stream()
                        .sorted(
                                Comparator.comparing(
                                        ModelDefinition::javaName))
                        .toList();

        return new ModelSchema(
                1,
                trinoVersion,
                List.copyOf(rootClassNames),
                sortedModels);
    }

    private ExtractedModel extractModel(
            Class<?> modelClass)
    {
        JavaType javaType =
                objectMapper
                        .getTypeFactory()
                        .constructType(modelClass);

        BeanDescription description =
                objectMapper
                        .getDeserializationConfig()
                        .introspect(javaType);

        List<IndexedProperty> indexedProperties =
                new ArrayList<>();

        Set<Class<?>> referencedModels =
                new HashSet<>();

        int discoveryIndex = 0;

        for (BeanPropertyDefinition property :
                description.findProperties()) {
            AnnotatedParameter constructorParameter =
                    property.getConstructorParameter();

            /*
             * 既存modelgenとの互換性を優先し、
             * @JsonCreator constructor parameterのみを対象にする。
             */
            if (constructorParameter == null) {
                continue;
            }

            JavaType propertyType =
                    constructorParameter.getType();

            TypeClassifier.Classification classification;

            try {
                classification =
                        typeClassifier.classify(
                                propertyType);
            }
            catch (RuntimeException exception) {
                throw new IllegalArgumentException(
                        "Failed to classify property: "
                                + modelClass.getName()
                                + "#"
                                + property.getName()
                                + " [javaName="
                                + property.getInternalName()
                                + ", type="
                                + propertyType.toCanonical()
                                + ", creatorParameter=true]",
                        exception);
            }

            referencedModels.addAll(
                    classification.referencedModels());

            int creatorIndex =
                    constructorParameter.getIndex();

            String javaName =
                    property.getInternalName() == null
                            ? property.getName()
                            : property.getInternalName();

            String nullability =
                    determineNullability(
                            property,
                            constructorParameter,
                            propertyType);

            PropertyDefinition definition =
                    new PropertyDefinition(
                            property.getName(),
                            javaName,
                            creatorIndex,
                            nullability,
                            classification.type());

            indexedProperties.add(
                    new IndexedProperty(
                            definition,
                            creatorIndex,
                            discoveryIndex));

            discoveryIndex++;
        }

        if (indexedProperties.isEmpty()) {
            String modelKind;

            if (modelClass.isInterface()) {
                modelKind = "interface";
            }
            else if (Modifier.isAbstract(
                    modelClass.getModifiers())) {
                modelKind = "abstract class";
            }
            else if (modelClass.isRecord()) {
                modelKind = "record";
            }
            else {
                modelKind = "class";
            }

            throw new IllegalStateException(
                    "Jackson found no deserializable "
                            + "constructor properties for "
                            + modelClass.getName()
                            + " ("
                            + modelKind
                            + ").");
        }

        indexedProperties.sort(
                Comparator.comparingInt(
                                IndexedProperty::creatorIndex)
                        .thenComparingInt(
                                IndexedProperty::discoveryIndex));

        List<PropertyDefinition> properties =
                indexedProperties.stream()
                        .map(IndexedProperty::definition)
                        .toList();

        String kind =
                modelClass.isRecord()
                        ? "record"
                        : "class";

        ModelDefinition definition =
                new ModelDefinition(
                        modelClass.getName(),
                        modelClass.getSimpleName(),
                        kind,
                        properties);

        referencedModels.remove(modelClass);

        return new ExtractedModel(
                definition,
                Set.copyOf(referencedModels));
    }

    private static String determineNullability(
            BeanPropertyDefinition property,
            AnnotatedParameter constructorParameter,
            JavaType propertyType)
    {
        Class<?> rawClass =
                propertyType.getRawClass();

        if (rawClass.isPrimitive()) {
            return "non_null";
        }

        if (rawClass == java.util.Optional.class
                || rawClass == java.util.OptionalInt.class
                || rawClass == java.util.OptionalLong.class
                || rawClass == java.util.OptionalDouble.class) {
            return "nullable";
        }

        if (hasNullableAnnotation(
                constructorParameter)) {
            return "nullable";
        }

        if (property.isRequired()) {
            return "non_null";
        }

        return "unknown";
    }

    private static boolean hasNullableAnnotation(
            AnnotatedMember member)
    {
        if (member == null) {
            return false;
        }

        for (Annotation annotation :
                member.annotations()) {
            String simpleName =
                    annotation
                            .annotationType()
                            .getSimpleName();

            if (simpleName.equals("Nullable")) {
                return true;
            }
        }

        return false;
    }

    private static List<String> readConfigLines(
            Path path)
            throws IOException
    {
        return Files.readAllLines(path).stream()
                .map(String::trim)
                .filter(line -> !line.isEmpty())
                .filter(line ->
                        !line.startsWith("#"))
                .toList();
    }

    private record ExtractedModel(
            ModelDefinition definition,
            Set<Class<?>> referencedModels)
    {
    }

    private record IndexedProperty(
            PropertyDefinition definition,
            int creatorIndex,
            int discoveryIndex)
    {
    }

    private record Arguments(
            String trinoVersion,
            Path roots,
            Path output)
    {
        static Arguments parse(String[] args)
        {
            if (args.length % 2 != 0) {
                throw new IllegalArgumentException(
                        "Arguments must be provided "
                                + "as name/value pairs.");
            }

            Map<String, String> values =
                    new HashMap<>();

            for (int index = 0;
                 index < args.length;
                 index += 2) {
                values.put(
                        args[index],
                        args[index + 1]);
            }

            return new Arguments(
                    required(
                            values,
                            "--trino-version"),
                    Path.of(
                            required(
                                    values,
                                    "--roots")),
                    Path.of(
                            required(
                                    values,
                                    "--output")));
        }

        private static String required(
                Map<String, String> values,
                String name)
        {
            String value =
                    values.get(name);

            if (value == null
                    || value.isBlank()) {
                throw new IllegalArgumentException(
                        "Missing required argument: "
                                + name);
            }

            return value;
        }
    }
}
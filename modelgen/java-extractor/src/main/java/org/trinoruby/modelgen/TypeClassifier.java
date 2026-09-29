package org.trinoruby.modelgen;

import com.fasterxml.jackson.annotation.JsonValue;
import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.type.TypeFactory;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.OptionalDouble;
import java.util.OptionalInt;
import java.util.OptionalLong;
import java.util.Set;

import static org.trinoruby.modelgen.ModelSchema.TypeDefinition;

public final class TypeClassifier
{
    private final TypeFactory typeFactory;

    public TypeClassifier(
            TypeFactory typeFactory)
    {
        this.typeFactory = typeFactory;
    }

    public Classification classify(JavaType type)
    {
        Class<?> rawClass = type.getRawClass();
        String className = rawClass.getName();

        /*
         * Primitive and Wrapper for primitive.
         */
        if (rawClass.isPrimitive()
                || isPrimitiveWrapper(rawClass)) {
            return Classification.withoutModels(
                    TypeDefinition.primitive(className));
        }

        /*
         * Optional<T>.
         */
        if (rawClass == Optional.class) {
            Classification element = classify(
                    requireElementType(type));

            return new Classification(
                    TypeDefinition.optional(element.type()),
                    element.referencedModels());
        }

        if (rawClass == OptionalInt.class) {
            return Classification.withoutModels(
                    TypeDefinition.optional(
                            TypeDefinition.primitive(
                                    Integer.class.getName())));
        }

        if (rawClass == OptionalLong.class) {
            return Classification.withoutModels(
                    TypeDefinition.optional(
                            TypeDefinition.primitive(
                                    Long.class.getName())));
        }

        if (rawClass == OptionalDouble.class) {
            return Classification.withoutModels(
                    TypeDefinition.optional(
                            TypeDefinition.primitive(
                                    Double.class.getName())));
        }

        /*
         * Array.
         */
        if (rawClass.isArray()) {
            Classification element = classify(
                    requireElementType(type));

            return new Classification(
                    TypeDefinition.array(element.type()),
                    element.referencedModels());
        }

        /*
         * Map<K, V>.
         */
        if (Map.class.isAssignableFrom(rawClass)) {
            Classification key = classify(
                    requireMapKeyType(type));

            Classification value = classify(
                    requireMapValueType(type));

            return new Classification(
                    TypeDefinition.map(
                            key.type(),
                            value.type()),
                    union(
                            key.referencedModels(),
                            value.referencedModels()));
        }

        /*
         * Set<T>.
         */
        if (Set.class.isAssignableFrom(rawClass)) {
            Classification element = classify(
                    requireElementType(type));

            return new Classification(
                    TypeDefinition.set(element.type()),
                    element.referencedModels());
        }

        /*
         * List<T> and something.
         */
        if (Collection.class.isAssignableFrom(rawClass)) {
            Classification element = classify(
                    requireElementType(type));

            return new Classification(
                    TypeDefinition.list(element.type()),
                    element.referencedModels());
        }

        /*
         * Enum.
         */
        if (rawClass.isEnum()) {
            List<String> values =
                    Arrays.stream(rawClass.getEnumConstants())
                            .map(Object::toString)
                            .toList();

            return Classification.withoutModels(
                    TypeDefinition.enumType(
                            className,
                            values));
        }

        /*
         * value object with @JsonValue
         *
         * TransactionId:
         *   TransactionId -> String
         *
         * ResourceGroupId:
         *   ResourceGroupId -> List<String>
         *
         */
        JavaType jsonValueType =
                findJsonValueType(rawClass);

        if (jsonValueType != null) {
            if (jsonValueType.getRawClass() == rawClass) {
                throw new IllegalStateException(
                        "@JsonValue recursively refers to its own type: "
                                + className);
            }

            Classification wireClassification =
                    classify(jsonValueType);

            return new Classification(
                    TypeDefinition.value(
                            className,
                            wireClassification.type()),
                    wireClassification.referencedModels());
        }

        /*
         * Do not analyze the internal structure of interfaces or abstract classes.
         *
         */
        if (rawClass.isInterface()
                || Modifier.isAbstract(
                rawClass.getModifiers())) {
            return Classification.withoutModels(
                    TypeDefinition.opaque(className));
        }

        /*
         * Do not analyze the internal structure of types external to Trino.
         *
         * URI, Instant, Locale, DataSize and so on.
         */
        if (!isTrinoModel(rawClass)) {
            return Classification.withoutModels(
                    TypeDefinition.opaque(className));
        }

        /*
         * Recursively analyze concrete Trino classes and records as regular models.
         */
        return new Classification(
                TypeDefinition.model(className),
                Set.of(rawClass));
    }

    private JavaType findJsonValueType(Class<?> type)
    {
        List<JavaType> jsonValueTypes =
                new ArrayList<>();

        /*
         * Include inherited public methods in the analysis.
         */
        for (Method method : type.getMethods()) {
            JsonValue annotation =
                    method.getAnnotation(JsonValue.class);

            if (annotation == null
                    || !annotation.value()) {
                continue;
            }

            if (method.getParameterCount() != 0) {
                throw new IllegalStateException(
                        "@JsonValue method must not have parameters: "
                                + type.getName()
                                + "#"
                                + method.getName());
            }

            jsonValueTypes.add(
                    typeFactory.constructType(
                            method.getGenericReturnType()));
        }

        /*
         * “Also check cases where a field is annotated with @JsonValue.
         */
        for (Field field : type.getDeclaredFields()) {
            JsonValue annotation =
                    field.getAnnotation(JsonValue.class);

            if (annotation == null
                    || !annotation.value()) {
                continue;
            }

            jsonValueTypes.add(
                    typeFactory.constructType(
                            field.getGenericType()));
        }

        if (jsonValueTypes.isEmpty()) {
            return null;
        }

        if (jsonValueTypes.size() > 1) {
            throw new IllegalStateException(
                    "Multiple active @JsonValue members found: "
                            + type.getName());
        }

        return jsonValueTypes.getFirst();
    }

    private static boolean isPrimitiveWrapper(Class<?> type)
    {
        return type == String.class
                || type == Boolean.class
                || type == Byte.class
                || type == Short.class
                || type == Integer.class
                || type == Long.class
                || type == Float.class
                || type == Double.class
                || type == Character.class;
    }

    private static boolean isTrinoModel(Class<?> type)
    {
        String packageName =
                type.getPackageName();

        return packageName.equals("io.trino")
                || packageName.startsWith("io.trino.");
    }

    private static JavaType requireElementType(
            JavaType type)
    {
        JavaType elementType =
                type.getContentType();

        /*
         * For some JavaTypes, such as Optional, the content type can be obtained from containedType(0) even when getContentType() returns null.
         */
        if (elementType == null
                && type.containedTypeCount() >= 1) {
            elementType = type.containedType(0);
        }

        if (elementType == null) {
            throw new IllegalArgumentException(
                    "Type does not have an element type: "
                            + type.toCanonical()
                            + " [javaTypeClass="
                            + type.getClass().getName()
                            + ", containedTypeCount="
                            + type.containedTypeCount()
                            + "]");
        }

        return elementType;
    }

    private static JavaType requireMapKeyType(
            JavaType type)
    {
        JavaType keyType =
                type.getKeyType();

        if (keyType == null
                && type.containedTypeCount() >= 1) {
            keyType = type.containedType(0);
        }

        if (keyType == null) {
            throw new IllegalArgumentException(
                    "Map type does not have a key type: "
                            + type.toCanonical()
                            + " [javaTypeClass="
                            + type.getClass().getName()
                            + ", containedTypeCount="
                            + type.containedTypeCount()
                            + "]");
        }

        return keyType;
    }

    private static JavaType requireMapValueType(
            JavaType type)
    {
        JavaType valueType =
                type.getContentType();

        if (valueType == null
                && type.containedTypeCount() >= 2) {
            valueType = type.containedType(1);
        }

        if (valueType == null) {
            throw new IllegalArgumentException(
                    "Map type does not have a value type: "
                            + type.toCanonical()
                            + " [javaTypeClass="
                            + type.getClass().getName()
                            + ", containedTypeCount="
                            + type.containedTypeCount()
                            + "]");
        }

        return valueType;
    }

    private static Set<Class<?>> union(
            Set<Class<?>> first,
            Set<Class<?>> second)
    {
        Set<Class<?>> result =
                new HashSet<>(first);

        result.addAll(second);

        return Set.copyOf(result);
    }

    public record Classification(
            TypeDefinition type,
            Set<Class<?>> referencedModels)
    {
        public Classification
        {
            referencedModels =
                    Set.copyOf(referencedModels);
        }

        public static Classification withoutModels(
                TypeDefinition type)
        {
            return new Classification(
                    type,
                    Set.of());
        }
    }
}
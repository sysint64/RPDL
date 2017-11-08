/**
 * Mixin for retrieving values from the parsed tree by path
 *
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpdl.accessors;

/// Mixin for retrieving values from the parsed tree by path
mixin template Accessors() {

// Nodes ------------------------------------------------------------------------------------------

    /**
     * Find `rpdl.node.ObjectNode` by `path`
     *
     * Throw: `rpdl.exception.NotObjectException`, `rpdl.exception.NotFoundException`
     * See_also: `optObject`
     */
    alias getObject = getTypedNode!(ObjectNode, NotObjectException);

    /**
     * Find `rpdl.node.Parameter` by `path`
     *
     * Throw: `rpdl.exception.NotParameterException`, `rpdl.exception.NotFoundException`
     * See_also: `optParameter`
     */
    alias getParameter = getTypedNode!(Parameter, NotParameterException);

    /**
     * Find `rpdl.value.Value` by `path`
     *
     * Throw: `rpdl.exception.NotValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optValue`
     */
    alias getValue = getTypedNode!(Value, NotValueException);

    /**
     * Find `rpdl.value.NumberValue` by `path`
     *
     * Throw: `rpdl.exception.NotNumberValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optNumberValue`
     */
    alias getNumberValue = getTypedNode!(NumberValue, NotNumberValueException);

    /**
     * Find `rpdl.value.StringValue` by `path`
     *
     * Throw: `rpdl.exception.NotStringValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optStringValue`
     */
    alias getStringValue = getTypedNode!(StringValue, NotStringValueException);

    /**
     * Find `rpdl.value.IdentifierValue` by `path`
     *
     * Throw: `rpdl.exception.NotIdentifierValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optIdentifierValue`
     */
    alias getIdentifierValue = getTypedNode!(IdentifierValue, NotIdentifierValueException);

    /**
     * Find `rpdl.value.BooleanValue` by `path`
     *
     * Throw: `rpdl.exception.NotBooleanValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optBooleanValue`
     */
    alias getBooleanValue = getTypedNode!(BooleanValue, NotBooleanValueException);

    /**
     * Find `rpdl.value.ArrayValue` by `path`
     *
     * Throw: `rpdl.exception.NotArrayValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optArrayValue`
     */
    alias getArrayValue = getTypedNode!(ArrayValue, NotArrayValueException);

// Vectors ----------------------------------------------------------------------------------------

    /**
     * Retrieve `vec2f` value from found node by `path`
     *
     * Throw: `rpdl.exception.NotVec2Exception`, `rpdl.exception.NotFoundException`
     * See_also: `optVec2f`
     */
    alias getVec2f = getVecValue!(float, 2, NotVec2Exception);

    /**
     * Retrieve `vec3f` value from found node by `path`
     *
     * Throw: `rpdl.exception.NotVec3Exception`, `rpdl.exception.NotFoundException`
     * See_also: `optVec3f`
     */
    alias getVec3f = getVecValue!(float, 3, NotVec3Exception);

    /**
     * Retrieve `vec4f` value from found node by `pathy`
     *
     * Throw: `rpdl.exception.NotVec4Exception`, `rpdl.exception.NotFoundException`
     * See_also: `optVec4f`
     */
    alias getVec4f = getVecValue!(float, 4, NotVec4Exception);

    /**
     * Retrieve `vec2i` value from found node by `path`
     *
     * Throw: `rpdl.exception.NotVec2Exception`, `rpdl.exception.NotFoundException`
     * See_also: `optVec2i`
     */
    alias getVec2i = getVecValue!(int, 2, NotVec2Exception);

    /**
     * Retrieve `vec3i` value from found node by `path`
     *
     * Throw: `rpdl.exception.NotVec3Exception`, `rpdl.exception.NotFoundException`
     * See_also: `optVec3i`
     */
    alias getVec3i = getVecValue!(int, 3, NotVec3Exception);

    /**
     * Retrieve `vec4i` value from found node by `path`
     *
     * Throw: `rpdl.exception.NotVec4Exception`, `rpdl.exception.NotFoundException`
     * See_also: `optVec4i`
     */
    alias getVec4i = getVecValue!(int, 4, NotVec4Exception);

    /**
     * Retrieve `vec2ui` value from found node by `path`
     *
     * Throw: `rpdl.exception.NotVec2Exception`, `rpdl.exception.NotFoundException`
     * See_also: `optVec2ui`
     */
    alias getVec2ui = getVecValue!(uint, 2, NotVec2Exception);

    /**
     * Retrieve `vec3ui` value from found node by `path`
     *
     * Throw: `rpdl.exception.NotVec3Exception`, `rpdl.exception.NotFoundException`
     * See_also: `optVec3ui`
     */
    alias getVec3ui = getVecValue!(uint, 3, NotVec3Exception);

    /**
     * Retrieve `vec4ui` value from found node by `path`
     *
     * Throw: `rpdl.exception.NotVec4Exception`, `rpdl.exception.NotFoundException`
     * See_also: `optVec4ui`
     */
    alias getVec4ui = getVecValue!(uint, 4, NotVec4Exception);

    /**
     * Retrieve normilized color to 1 i.e. r/255, g/255, b/255, a/100
     *
     * Returns:
     *     `vec4f` value contains inside the node
     *     if `rpdl.node.Node` has 3 components, then `alpha` will set to 1
     *
     * Throw:
     *     `rpdl.exception.NotVec4Exception`,
     *     `rpdl.exception.NotVec3Exception`,
     *     `rpdl.exception.NotFoundException`
     *
     * See_also: `getVec3f`, `getVec4f`, `optVec3f`, `optVec4f`
     */
    vec4 getNormColor(in string path) {
        vec4 color;

        try {
            color = getVec4f(path);
        } catch(NotVec4Exception) {
            vec3 color3 = getVec3f(path);
            color = vec4(color3, 1.0f);
        } catch(NotVec3Exception) {
            throw new NotVec3OrVec4Exception();
        }

        color = vec4(color.r / 255.0f, color.g / 255.0f, color.b / 255.0f, color.a / 100.0f);
        return color;
    }

// Optional access --------------------------------------------------------------------------------

    /**
     * Find `rpdl.node.Node` by `path`
     * if node was not found then it will return `defaultVal`
     */
    Node optNode(in string path, Node defaultVal = null) {
        Node node = findNodeByPath(path, getRootNode());

        if (node is null)
            return defaultVal;

        return node;
    }

    /**
     * Find `rpdl.node.ObjectNode` by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotObjectException`
     * See_also: `getObject`
     */
    alias optObject = optTypedNode!(ObjectNode, NotObjectException);

    /**
     * Find `rpdl.node.Parameter` by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotParameterException`
     * See_also: `getParameter`
     */
    alias optParameter = optTypedNode!(Parameter, NotParameterException);

    /**
     * Find `rpdl.value.Value` by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotValueException`
     * See_also: `getValue`
     */
    alias optValue = optTypedNode!(Value, NotValueException);

    /**
     * Find `rpdl.value.NumberValue` by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotNumberValueException`
     * See_also: `getNumberValue`
     */
    alias optNumberValue = optTypedNode!(NumberValue, NotNumberValueException);

    /**
     * Find `rpdl.value.StringValue` by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotStringValueException`
     * See_also: `getStringValue`
     */
    alias optStringValue = optTypedNode!(StringValue, NotStringValueException);

    /**
     * Find `rpdl.value.IdentifierValue` by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotIdentifierValueException`
     * See_also: `getIdentifierValue`
     */
    alias optIdentifierValue = optTypedNode!(IdentifierValue, NotIdentifierValueException);

    /**
     * Find `rpdl.value.BooleanValue` by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotBooleanValueException`
     * See_also: `getBooleanValue`
     */
    alias optBooleanValue = optTypedNode!(BooleanValue, NotBooleanValueException);

    /**
     * Find `rpdl.value.ArrayValue` by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotArrayValueException`
     * See_also: `getArrayValue`
     */
    alias optArrayValue = optTypedNode!(ArrayValue, NotArrayValueException);

// Access to values from Nodes ---------------------------------------------------------------------

    /**
     * Retrieve `float` value in `rpdl.value.NumberValue` by `path`
     *
     * Throw: `rpdl.exception.NotNumberValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optNumber`
     */
    alias getNumber = getTypedValue!(float, NumberValue, NotNumberValueException);

    /**
     * Retrieve `bool` value in `rpdl.value.BooleanValue` by `path`
     *
     * Throw: `rpdl.exception.NotBooleanValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optBoolean`
     */
    alias getBoolean = getTypedValue!(bool, BooleanValue, NotBooleanValueException);

    /**
     * Retrieve `string` value in `rpdl.value.StringValue` by `path`
     *
     * Throw: `rpdl.exception.NotStringValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optString`
     */
    alias getString = getTypedValue!(string, StringValue, NotStringValueException);

    /**
     * Retrieve `string` value in `rpdl.value.IdentifierValue` by `path`
     *
     * Throw: `rpdl.exception.NotIdentifierValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optIdentifier`
     */
    alias getIdentifier = getTypedValue!(string, IdentifierValue, NotIdentifierValueException);

    /**
     * Retrieve `dstring` value in `rpdl.value.StringValue` by `path`
     *
     * Throw: `rpdl.exception.NotStringValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optUTFString`
     */
    dstring getUTFString(in string path) {
        return getTypedNode!(StringValue, NotStringValueException)(path).utfValue;
    }

    /**
     * Retrieve `int` value in `rpdl.value.NumberValue` by `path`
     *
     * Throw: `rpdl.exception.NotNumberValueException`, `rpdl.exception.NotFoundException`
     * See_also: `optInteger`
     */
    int getInteger(in string path) {
        return to!int(getNumber(path));
    }

// Optional access to values from Nodes ------------------------------------------------------------

    /**
     * Retrieve optional `float` in node with type `rpdl.value.NumberValue` value by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotNumberValueException`
     * See_also: `getNumber`
     */
    alias optNumber = optTypedValue!(float, NumberValue, NotNumberValueException);

    /**
     * Retrieve optional `bool` in node with type `rpdl.value.BooleanValue` value by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotBooleanValueException`
     * See_also: `getBoolean`
     */
    alias optBoolean = optTypedValue!(bool, BooleanValue, NotBooleanValueException);

    /**
     * Retrieve optional `string` in node with type `rpdl.value.StringValue` value by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotStringValueException`
     * See_also: `getString`
     */
    alias optString = optTypedValue!(string, StringValue, NotStringValueException);

    /**
     * Retrieve optional `string` in node with type `rpdl.value.IdentifierValue` value by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotIdentifierValueException`
     * See_also: `getIdentifier`
     */
    alias optIdentifier = optTypedValue!(string, IdentifierValue, NotIdentifierValueException);

    /**
     * Retrieve optional `dstring` in node with type `rpdl.value.StringValue` value by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotStringValueException`
     * See_also: `getUTFString`
     */
    dstring optUTFString(in string path, dstring defaultVal = dstring.init) {
        StringValue node = optTypedNode!(StringValue, NotStringValueException)(path, null);

        if (node is null)
            return defaultVal;

        return node.utfValue;
    }

    /**
     * Retrieve optional `int` in node with type `rpdl.value.NumberValue` value by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotNumberValueException`
     * See_also: `getInteger`
     */
    int optInteger(in string path, int defaultVal = 0) {
        return to!int(optNumber(path, to!float(defaultVal)));
    }

    /**
     * Retrieve optional `vec2f` value from found node by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotVec2Exception`
     * See_also: `getVec2f`
     */
    alias optVec2f = optVecValue!(float, 2, NotVec2Exception);

    /**
     * Retrieve optional `vec3f` value from found node by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotVec3Exception`
     * See_also: `getVec3f`
     */
    alias optVec3f = optVecValue!(float, 3, NotVec3Exception);

    /**
     * Retrieve optional `vec4f` value from found node by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotVec4Exception`
     * See_also: `getVec4f`
     */
    alias optVec4f = optVecValue!(float, 4, NotVec4Exception);

    /**
     * Retrieve optional `vec2i` value from found node by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotVec2Exception`
     * See_also: `getVec2i`
     */
    alias optVec2i = optVecValue!(int, 2, NotVec2Exception);

    /**
     * Retrieve optional `vec3i` value from found node by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotVec3Exception`
     * See_also: `getVec3i`
     */
    alias optVec3i = optVecValue!(int, 3, NotVec3Exception);

    /**
     * Retrieve optional `vec4i` value from found node by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotVec4Exception`
     * See_also: `getVec4i`
     */
    alias optVec4i = optVecValue!(int, 4, NotVec4Exception);

    /**
     * Retrieve optional `vec4ui` value from found node by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotVec2Exception`
     * See_also: `getVec2ui`
     */
    alias optVec2ui = optVecValue!(uint, 2, NotVec2Exception);

    /**
     * Retrieve optional `vec3ui` value from found node by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotVec3Exception`
     * See_also: `getVec3ui`
     */
    alias optVec3ui = optVecValue!(uint, 3, NotVec3Exception);

    /**
     * Retrieve optional `vec4ui` value by from found node `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `rpdl.exception.NotVec4Exception`
     * See_also: `getVec4ui`
     */
    alias optVec4ui = optVecValue!(uint, 4, NotVec4Exception);

    /**
     * Retrieve enum with type `T` value from found node by `path`
     *
     * Throw: `E`, `rpdl.exception.NotFoundException`
     * See_also: `optEnum`, `ufcsGetEnum`, `ufcsOptEnum`
     */
    T getEnum(T, E : RPDLException)(in string path) {
        const string val = getIdentifier(path);

        foreach (immutable enumItem; [EnumMembers!T]) {
            if (to!string(enumItem) == val) {
                return enumItem;
            }
        }

        throw new E();
    }

    /**
     * Retrieve optional enum with type `T` value from found node by `path`
     * if node was not found then it will return `defaultVal`
     *
     * Throw: `E`
     * See_also: `getEnum`, `ufcsGetEnum`, `ufcsOptEnum`
     */
    T optEnum(T, E : RPDLException)(in string path, in T defaultVal = T.init) {
        try {
            return getEnum!(T, E)(path);
        } catch (NotFoundException) {
            return defaultVal;
        }
    }

// Helper methods for access to nodes and values by path -------------------------------------------

    /**
     * Find typed node by `path`, node should be inherited from `T`.
     *
     * Throw: `E`, `NotFoundException`
     * See_also: `optTypedNode`, `getTypedValue`, `optTypedValue`
     */
    private T getTypedNode(T : Node, E : RPDLException)(in string path) {
        Node node = findNodeByPath(path, getRootNode());

        if (node is null)
            throw new NotFoundException("Node with path \"" ~ path ~ "\" not found");

        T object = cast(T)(node);

        if (object is null)
            throw new E("Node with path \"" ~ path ~ "\" is not an " ~ E.typeName);

        return cast(T)(node);
    }

    /**
     * Get node by `path` and retrieve value from this node.
     * Node should be ingerited from `N` and value should be inherited from `T`.
     *
     * Throw: `E`, `NotFoundException`
     * See_also: `optTypedNode`, `getTypedNode`, `optTypedValue`
     */
    private T getTypedValue(T, N : Node, E : RPDLException)(in string path) {
        return getTypedNode!(N, E)(path).value;
    }

    /**
     * Get node by `path`, node should be inherited from `T`.
     * If node was not found then it will return `defaultVal`.
     *
     * Throw: `E`, `NotFoundException`
     * See_also: `optTypedNode`, `getTypedValue`, `optTypedValue`
     */
    private T optTypedNode(T : Node, E : RPDLException)(in string path, T defaultVal) {
        Node node = findNodeByPath(path, getRootNode());

        if (node is null)
            return defaultVal;

        T object = cast(T)(node);

        if (object is null)
            throw new E("Node with path \"" ~ path ~ "\" is not an " ~ E.typeName);

        return cast(T)(node);
    }

    /**
     * Get node by `path` and retrieve value from this node.
     * Node should be ingerited from `N` and value should be inherited from `T`.
     * If node was not found then it will return `defaultVal`.
     *
     * Throw: `E`
     * See_also: `getTypedValue`, `getTypedNode`, `optTypedNode`
     */
    private T optTypedValue(T, N : Node, E : RPDLException)(in string path, T defaultVal = T.init) {
        N node = optTypedNode!(N, E)(path, null);

        if (node is null)
            return defaultVal;

        return node.value;
    }

    /**
     * This method retrieves vector value from node by `path`, size of vector is `n`
     * and type of their components is `T`.
     *
     * Throw: `E`, `NotFoundException`
     * See_also: `getVecValueFromNode`, `optVecValue`
     */
    private Vector!(T, n) getVecValue(T, int n, E : RPDLException)(in string path) {
        Node node = getNode(path);

        if (node is null)
            throw new NotFoundException("Node with path \"" ~ path ~ "\" not found");

        return getVecValueFromNode!(T, n, E)(node);
    }

    /**
     * This method retrieves vector value from particular `node`. Size of vector is `n`
     * and type of their components is `T`.
     * If node was not found then method will return `defaultVal`.
     *
     * Throw: `E` when length of components not equals `n` or one of child components is null
     * See_also: `getVecValue`, `optVecValue`
     */
    private Vector!(T, n) getVecValueFromNode(T, int n, E : RPDLException)(Node node) {
        if (node.length != n)
            throw new E();

        NumberValue[n] vectorComponents;
        T[n] values;

        for (int i = 0; i < n; ++i) {
            vectorComponents[i] = cast(NumberValue) node.getAtIndex(i);

            if (vectorComponents[i] is null)
                throw new E();

            values[i] = to!T(vectorComponents[i].value);
        }

        return Vector!(T, n)(values);
    }

    /**
     * This method retrieves vector value from node by `path`, size of vector is `n`
     * and type of their components is `T`.
     * If node was not found then method will return `defaultVal`.
     *
     * Throw: `E`, `NotFoundException`
     * See_also: `getVecValue`, `getVecValueFromNode`
     */
    private Vector!(T, n) optVecValue(T, int n, E : RPDLException)(in string path,
        Vector!(T, n) defaultVal = Vector!(T, n).init)
    {
        Node node = findNodeByPath(path, getRootNode());

        if (node is null)
            return defaultVal;

        return getVecValueFromNode!(T, n, E)(node);
    }
}

import rpdl.exception;
import rpdl.node;

/// UFCS method for `Accessors.getEnum`
T ufcsGetEnum(T, E : RPDLException)(Node node, in string path) {
    return node.getEnum!(T, E)(path);
}

/// UFCS method for `Accessors.optEnum`
T ufcsOptEnum(T, E : RPDLException)(Node node, in string path, in T defaultVal = T.init) {
    return node.optEnum!(T, E)(path, defaultVal);
}

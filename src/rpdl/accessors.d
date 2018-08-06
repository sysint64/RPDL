/**
 * Mixin for retrieving values from the parsed tree by path
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpdl.accessors;

/**
 * Mixin for retrieving values from the parsed tree by path.
 * To access to variables you can use `get` or `opt` methods e.g. `getParameter` will
 * return `rpdl.node.Parameter`, i.e. function name builds from prefix (get or opt) and
 * type name. If method starts with `get`, then method can throw an exception
 * if value will not find by the path. If you use `opt`, then exception will not thrown
 * if value didn't found, also you can set default value for value which not found.
 * If value found but has wrong type you will get `WrongNodeType` exception.
 */
mixin template Accessors() {
    alias getObjectNode = getTypedNode!(ObjectNode);
    alias getParameterNode = getTypedNode!(Parameter);
    alias getValueNode = getTypedNode!(Value);
    alias getNumberValueNode = getTypedNode!(NumberValue);
    alias getStringValueNode = getTypedNode!(StringValue);
    alias getIdentifierValueNode = getTypedNode!(IdentifierValue);
    alias getBooleanValueNode = getTypedNode!(BooleanValue);
    alias getArrayValueNode = getTypedNode!(ArrayValue);

    alias optObjectNode = optTypedNode!(ObjectNode);
    alias optParameterNode = optTypedNode!(Parameter);
    alias optValueNode = optTypedNode!(Value);
    alias optNumberValueNode = optTypedNode!(NumberValue);
    alias optStringValueNode = optTypedNode!(StringValue);
    alias optIdentifierValueNode = optTypedNode!(IdentifierValue);
    alias optBooleanValueNode = optTypedNode!(BooleanValue);
    alias optArrayValueNode = optTypedNode!(ArrayValue);

    alias getNumber = getTypedValue!(float, NumberValue);
    alias getBoolean = getTypedValue!(bool, BooleanValue);
    alias getString = getTypedValue!(string, StringValue);
    alias getIdentifier = getTypedValue!(string, IdentifierValue);

    alias optNumber = optTypedValue!(float, NumberValue);
    alias optBoolean = optTypedValue!(bool, BooleanValue);
    alias optString = optTypedValue!(string, StringValue);
    alias optIdentifier = optTypedValue!(string, IdentifierValue);

    dstring getUTF32String(in string path) {
        return getTypedNode!(StringValue)(path).utf32Value;
    }

    int getInteger(in string path) {
        return to!int(getNumber(path));
    }

    dstring optUTF32String(in string path, dstring defaultVal = dstring.init) {
        StringValue node = optTypedNode!(StringValue)(path, null);

        if (node is null)
            return defaultVal;

        return node.utf32Value;
    }

    int optInteger(in string path, int defaultVal = 0) {
        return to!int(optNumber(path, to!float(defaultVal)));
    }

    alias getVec2f = getVecValue!(float, 2);
    alias getVec3f = getVecValue!(float, 3);
    alias getVec4f = getVecValue!(float, 4);
    alias getVec2i = getVecValue!(int, 2);
    alias getVec3i = getVecValue!(int, 3);
    alias getVec4i = getVecValue!(int, 4);
    alias getVec2ui = getVecValue!(uint, 2);
    alias getVec3ui = getVecValue!(uint, 3);
    alias getVec4ui = getVecValue!(uint, 4);

    alias optVec2f = optVecValue!(float, 2);
    alias optVec3f = optVecValue!(float, 3);
    alias optVec4f = optVecValue!(float, 4);
    alias optVec2i = optVecValue!(int, 2);
    alias optVec3i = optVecValue!(int, 3);
    alias optVec4i = optVecValue!(int, 4);
    alias optVec2ui = optVecValue!(uint, 2);
    alias optVec3ui = optVecValue!(uint, 3);
    alias optVec4ui = optVecValue!(uint, 4);

    /**
     * Retrieve normilized color to 1 i.e. r/255, g/255, b/255, a/100.
     *
     * Returns:
     *     `vec4f` value contains inside the node
     *     if `rpdl.node.Node` has 3 components, then `alpha` will set to 1.
     */
    vec4 getNormColor(in string path) {
        vec4 color;

        try {
            color = getVec4f(path);
        } catch(WrongNodeType) {
            try {
                vec3 color3 = getVec3f(path);
                color = vec4(color3, 100.0f);
            } catch(WrongNodeType) {
                throw new WrongNodeType(path, "color(vec4 or vec3)");
            }
        }

        color = vec4(color.r / 255.0f, color.g / 255.0f, color.b / 255.0f, color.a / 100.0f);
        return color;
    }

    /**
     * Retrieve enum with type `T` value from found node by `path`
     * See_also: `optEnum`, `ufcsGetEnum`, `ufcsOptEnum`
     */
    T getEnum(T)(in string path) {
        const string val = getIdentifier(path);

        foreach (immutable enumItem; [EnumMembers!T]) {
            if (to!string(enumItem) == val) {
                return enumItem;
            }
        }

        throw new WrongNodeType(path, T.stringof);
    }

    /**
     * Retrieve optional enum with type `T` value from found node by `path`
     * if node was not found then it will return `defaultVal`
     * See_also: `getEnum`, `ufcsGetEnum`, `ufcsOptEnum`
     */
    T optEnum(T)(in string path, in T defaultVal = T.init) {
        try {
            return getEnum!(T)(path);
        } catch (NotFoundException) {
            return defaultVal;
        }
    }

// Helper methods for access to nodes and values by path -------------------------------------------

    /**
     * Find typed node by `path`, node should be inherited from `T`.
     * See_also: `optTypedNode`, `getTypedValue`, `optTypedValue`
     */
    private T getTypedNode(T : Node)(in string path) {
        Node node = findNodeByPath(path, getRootNode());

        if (node is null)
            throw new NotFoundException("Node with path \"" ~ path ~ "\" not found");

        T object = cast(T)(node);

        if (object is null)
            throw new WrongNodeType(path, T.stringof);

        return cast(T)(node);
    }

    /**
     * Get node by `path` and retrieve value from this node.
     * Node should be ingerited from `N` and value should be inherited from `T`.
     * See_also: `optTypedNode`, `getTypedNode`, `optTypedValue`
     */
    private T getTypedValue(T, N : Node)(in string path) {
        return getTypedNode!N(path).value;
    }

    /**
     * Get node by `path`, node should be inherited from `T`.
     * If node was not found then it will return `defaultVal`.
     * See_also: `optTypedNode`, `getTypedValue`, `optTypedValue`
     */
    private T optTypedNode(T : Node)(in string path, T defaultVal) {
        Node node = findNodeByPath(path, getRootNode());

        if (node is null)
            return defaultVal;

        T object = cast(T)(node);

        if (object is null)
            throw new WrongNodeType(path, T.stringof);

        return cast(T)(node);
    }

    /**
     * Get node by `path` and retrieve value from this node.
     * Node should be ingerited from `N` and value should be inherited from `T`.
     * If node was not found then it will return `defaultVal`.
     * See_also: `getTypedValue`, `getTypedNode`, `optTypedNode`
     */
    private T optTypedValue(T, N : Node)(in string path, T defaultVal = T.init) {
        N node = optTypedNode!N(path, null);

        if (node is null)
            return defaultVal;

        return node.value;
    }

    /**
     * This method retrieves vector value from node by `path`, size of vector is `n`
     * and type of their components is `T`.
     *
     * See_also: `getVecValueFromNode`, `optVecValue`
     */
    private Vector!(T, n) getVecValue(T, int n)(in string path) {
        Node node = getNode(path);

        if (node is null)
            throw new NotFoundException("Node with path \"" ~ path ~ "\" not found");

        return getVecValueFromNode!(T, n)(path, node);
    }

    /**
     * This method retrieves vector value from particular `node`. Size of vector is `n`
     * and type of their components is `T`.
     * If node was not found then method will return `defaultVal`.
     * See_also: `getVecValue`, `optVecValue`
     */
    private Vector!(T, n) getVecValueFromNode(T, int n)(in string path, Node node) {
        if (node.length != n)
            throw new WrongNodeType(path, T.stringof);

        NumberValue[n] vectorComponents;
        T[n] values;

        for (int i = 0; i < n; ++i) {
            vectorComponents[i] = cast(NumberValue) node.getAtIndex(i);

            if (vectorComponents[i] is null)
                throw new WrongNodeType(path, T.stringof);

            values[i] = to!T(vectorComponents[i].value);
        }

        return Vector!(T, n)(values);
    }

    /**
     * This method retrieves vector value from node by `path`, size of vector is `n`
     * and type of their components is `T`.
     * If node was not found then method will return `defaultVal`.
     * See_also: `getVecValue`, `getVecValueFromNode`
     */
    private Vector!(T, n) optVecValue(T, int n)(in string path,
        Vector!(T, n) defaultVal = Vector!(T, n).init)
    {
        Node node = findNodeByPath(path, getRootNode());

        if (node is null)
            return defaultVal;

        return getVecValueFromNode!(T, n)(path, node);
    }
}

import rpdl.exception;
import rpdl.node;

/// UFCS method for `Accessors.getEnum`
T ufcsGetEnum(T)(Node node, in string path) {
    return node.getEnum!(T)(path);
}

/// UFCS method for `Accessors.optEnum`
T ufcsOptEnum(T)(Node node, in string path, in T defaultVal = T.init) {
    return node.optEnum!(T)(path, defaultVal);
}

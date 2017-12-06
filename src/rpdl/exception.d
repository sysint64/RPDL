/**
 * Available rpdl exceptions
 *
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpdl.exception;

/// Base RPDL Exception
class RPDLException : Exception {
    this() { super(""); }
    this(in string details) { super(details); }
}

/// Symbol not found int RPDL tree
class NotFoundException : RPDLException {
    this() { super("not found"); }
    this(in string details) { super(details); }
}

/// Including not allowet at compile time
class IncludeNotAllowedAtCTException : RPDLException {
    this() { super("include not allowed at compile time"); }
    this(in string details) { super(details); }
}

/// Found node is not an `rpdl.node.ObjectNode`
class NotObjectException : RPDLException {
    this() { super("it is not an object"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "ObjectNode"; }
}

/// Found node is not a parameter `rpdl.node.Parameter`
class NotParameterException : RPDLException {
    this() { super("it is not a parameter"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "Parameter"; }
}

/// Found node is not a `rpdl.value.Value`
class NotValueException : RPDLException {
    this() { super("it is not a value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "Value"; }
}

/// Found node is not a `rpdl.value.Value` nor `rpdl.node.Parameter`
class NotParameterOrValueException : RPDLException {
    this() { super("it is not a parameter or value"); }
    this(in string details) { super(details); }
}

/// Found node is not a `rpdl.value.NumberValue`
class NotNumberValueException : RPDLException {
    this() { super("it is not a number value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "NumberValue"; }
}

/// Found node is not a `rpdl.value.BooleanValue`
class NotBooleanValueException : RPDLException {
    this() { super("it is not a number value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "BooleanValue"; }
}

/// Found node is not a `rpdl.value.StringValue`
class NotStringValueException : RPDLException {
    this() { super("it is not a string value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "StringValue"; }
}

/// Found node is not a `rpdl.value.IdentifierValue`
class NotIdentifierValueException : RPDLException {
    this() { super("it is not a identifier value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "IdentifierValue"; }
}

/// Found node is not a `rpdl.value.ArrayValue`
class NotArrayValueException : RPDLException {
    this() { super("it is not an array value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "ArrayValue"; }
}

/// Found value is not a `vec2`
class NotVec2Exception : RPDLException {
    this() { super("it is not a vec2 value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "vec2"; }
}

/// Found value is not a `vec3`
class NotVec3Exception : RPDLException {
    this() { super("it is not a vec3 value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "vec3"; }
}

/// Found value is not a `vec4`
class NotVec4Exception : RPDLException {
    this() { super("it is not a vec4 value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "vec4"; }
}

/// Found value is not a `vec3` nor `vec4`
class NotVec3OrVec4Exception : RPDLException {
    this() { super("it is not a vec3 or vec4 value"); }
    this(in string details) { super(details); }
    static @property string typeName() { return "vec3 of vec4"; }
}

class WrongNodeType : RPDLException {
    this() { super("wrong type of value"); }
    this(in string details) { super(details); }
}

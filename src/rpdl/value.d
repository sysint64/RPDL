/**
 * Values nodes
 */
module rpdl.value;

import rpdl.node;
import std.conv;

/// Base class of value
class Value: Node {
    /// Type of value
    enum Type {Number, String, Identifier, Boolean, Array};

    this(in string name) { super(name); }
    this(in string name, Node parent) { super(name, parent); }

    @property Type type() { return p_type; }

protected:
    Type p_type;
}

class NumberValue: Value {
    @property float value() { return p_value; }

    this(in string name, in float value) {
        super(name);
        this.p_value = value;
        this.p_type = Type.Number;
    }

    override string toString() {
        return to!string(p_value);
    }

protected:
    float p_value;
}

class BooleanValue : Value {
    @property bool value() { return p_value; }

    this(in string name, in bool value) {
        super(name);
        this.p_value = value;
        this.p_type = Type.Boolean;
    }

    override string toString() {
        return to!string(p_value);
    }

private:
    bool p_value;
}

class StringValue : Value {
    @property string value() { return p_value; }
    @property dstring utfValue() { return p_utfValue; }

    this(in string name, in string value) {
        super(name);
        this.p_value = value;
        this.p_type = Type.String;
    }

    this(in string name, in string value, in dstring utfValue) {
        super(name);
        this.p_value = value;
        this.p_utfValue = utfValue;
        this.p_type = Type.String;
    }

    override string toString() {
        return "\"" ~ to!string(p_value) ~ "\"";
    }

private:
    string p_value;
    dstring p_utfValue;
}

class IdentifierValue : StringValue {
    this(in string name, in string value) {
        super(name, value);
        this.p_type = Type.Identifier;
    }

    this(in string name, in string value, in dstring utfValue) {
        super(name, value, utfValue);
        this.p_type = Type.Identifier;
    }

    override string toString() {
        return to!string(p_value);
    }
}

class ArrayValue: Value {
    this(in string name) {
        super(name);
        this.p_type = Type.Array;
    }
}

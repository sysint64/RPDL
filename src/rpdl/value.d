/**
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */
module rpdl.value;

import rpdl.node;
import std.conv;

class Value: Node {
    enum Type {Number, String, Identifier, Boolean, Array};

    this(in string name) { super(name); }
    this(in string name, Node parent) { super(name, parent); }

    @property Type type() { return p_type; }

    Value clone(in string name) {
        throw new Error("Not supported");
    }

protected:
    Type p_type;
}

final class NumberValue: Value {
    @property float value() { return p_value; }

    this(in string name, in float value) {
        super(name);
        this.p_value = value;
        this.p_type = Type.Number;
    }

    override string toString() {
        return to!string(p_value);
    }

    override Value clone(in string name) {
        return new NumberValue(name, value);
    }

private:
    float p_value;
}

final class BooleanValue : Value {
    @property bool value() { return p_value; }

    this(in string name, in bool value) {
        super(name);
        this.p_value = value;
        this.p_type = Type.Boolean;
    }

    override string toString() {
        return to!string(p_value);
    }

    override Value clone(in string name) {
        return new BooleanValue(name, value);
    }

private:
    bool p_value;
}

class StringValue : Value {
    @property string value() { return p_value; }
    @property dstring utf32Value() { return p_utfValue; }

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

    override Value clone(in string name) {
        return new StringValue(name, value, utf32Value);
    }

private:
    string p_value;
    dstring p_utfValue;
}

final class IdentifierValue : StringValue {
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

    override Value clone(in string name) {
        return new IdentifierValue(name, value);
    }
}

final class ArrayValue: Value {
    this(in string name) {
        super(name);
        this.p_type = Type.Array;
    }

    override Value clone(in string name) {
        auto array = new ArrayValue(name);

        foreach (child; children) {
            auto value = cast(Value) child;
            assert(value !is null);
            array.insert(value.clone(to!string(array.children.length)));
        }

        return array;
    }
}

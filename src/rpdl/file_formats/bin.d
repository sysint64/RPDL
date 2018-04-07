/**
 * Binary format (represents as bytecode)
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpdl.file_formats.bin;

import std.conv;

import rpdl.node;
import rpdl.value;
import rpdl.writer;
import rpdl.reader;

/// Available bytecode commands
enum OpCode {
    none = 0x00,
    end = 0x01,  /// End of node or file
    object = 0x02,  /// Represent `rpdl.node.ObjectNode`
    klass = 0x03,  /// Deprecated op code
    parameter = 0x04,  /// Represent `rpdl.node.Parameter`
    numberValue = 0x05,  /// Represent `rpdl.value.NumberValue`
    booleanValue = 0x06,  /// Represent `rpdl.value.BooleanValue`
    stringValue = 0x07,  /// Represent `rpdl.value.StringValue`
    identifierValue = 0x08,  /// Represent `rpdl.value.IdentifierValue`
    arrayValue = 0x09  /// Represent `rpdl.value.ArrayValue`
}

/// Tree writer to byte code
class BinWriter : Writer {
    this(Node root) { super(root); }

    override void save(in string fileName) {
        super.save(fileName);
        writeOpCode(OpCode.end);
    }

protected:
    /// Write name of `node` - pair of name length and name data.
    void writeName(Node node) {
        rawWrite(cast(ubyte) node.name.length);
        rawWrite(node.name);
    }

    /// Pair of string length and string data.
    void writeString(string str) {
        rawWrite(cast(ubyte) str.length);
        rawWrite(str);
    }

    void writeOpCode(OpCode code) {
        rawWrite(cast(ubyte) code);
    }

    override void writeObject(ObjectNode object) {
        writeOpCode(OpCode.object);
        writeName(object);
        super.writeObject(object);
        writeOpCode(OpCode.end);
    }

    override void writeParameter(Parameter parameter) {
        writeOpCode(OpCode.parameter);
        writeName(parameter);
        super.writeParameter(parameter);
        writeOpCode(OpCode.end);
    }

    override void writeNumberValue(NumberValue node) {
        writeOpCode(OpCode.numberValue);
        writeName(node);
        rawWrite(node.value);
    }

    override void writeBooleanValue(BooleanValue node) {
        writeOpCode(OpCode.booleanValue);
        writeName(node);
        rawWrite(node.value);
    }

    override void writeStringValue(StringValue node) {
        writeOpCode(OpCode.stringValue);
        writeName(node);
        writeString(node.value);
    }

    override void writeIdentifierValue(IdentifierValue node) {
        writeOpCode(OpCode.identifierValue);
        writeName(node);
        writeString(node.value);
    }

    override void writeArrayValue(ArrayValue array) {
        writeOpCode(OpCode.arrayValue);
        writeName(array);
        super.writeArrayValue(array);
        writeOpCode(OpCode.end);
    }
}

/// Tree reader from byte code.
class BinReader : Reader {
    this(Node root) { super(root); }

protected:
    ubyte currentOpCode = OpCode.none;

    T rawRead(T)() {
        T[1] buf;
        file.rawRead(buf);
        return buf[0];
    }

    alias readByte = rawRead!ubyte;
    alias readBoolean = rawRead!bool;
    alias readNumber = rawRead!float;

    string readString(in ubyte length) {
        char[] buf = new char[length];
        file.rawRead(buf);
        return cast(string) buf;
    }

    override void readObjects() {
        ubyte opCode;

        while (opCode != OpCode.end) {
            opCode = readByte();

            if (opCode == OpCode.end)
                break;

            if (opCode != OpCode.object)
                assert(false);  // TODO: throw an exception

            readObject(root);
        }
    }

    override void readObject(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);

        ObjectNode object = new ObjectNode(name);
        parent.insert(object);
        ubyte opCode = readByte();

        while (opCode != OpCode.end) {
            switch (opCode) {
                case OpCode.object:
                    readObject(object);
                    break;

                case OpCode.parameter:
                    readParameter(object);
                    break;

                default:
                    assert(false);  // TODO: throw an exception
            }

            opCode = readByte();
        }
    }

    override void readParameter(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);

        Parameter parameter = new Parameter(name);
        parent.insert(parameter);

        ubyte opCode = readByte();

        while (opCode != OpCode.end) {
            currentOpCode = opCode;
            readValue(parameter);
            opCode = readByte();
        }
    }

    override void readArrayValue(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);

        ArrayValue arrayNode = new ArrayValue(name);
        parent.insert(arrayNode);

        ubyte opCode = readByte();

        while (opCode != OpCode.end) {
            currentOpCode = opCode;
            readValue(arrayNode);
            opCode = readByte();
        }
    }

    override void readValue(Node parent) {
        switch (currentOpCode) {
            case OpCode.numberValue:
                readNumberValue(parent);
                break;

            case OpCode.booleanValue:
                readBooleanValue(parent);
                break;

            case OpCode.stringValue:
                readStringValue(parent);
                break;

            case OpCode.identifierValue:
                readIdentifierValue(parent);
                break;

            case OpCode.arrayValue:
                readArrayValue(parent);
                break;

            default:
                assert(false);  // TODO: throw an exception
        }
    }

    override void readNumberValue(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);
        const float value = readNumber();

        NumberValue valueNode = new NumberValue(name, value);
        parent.insert(valueNode);
    }

    override void readBooleanValue(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);
        const bool value = readBoolean();

        BooleanValue valueNode = new BooleanValue(name, value);
        parent.insert(valueNode);
    }

    override void readStringValue(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);

        const ubyte stringLength = readByte();
        const string value = readString(stringLength);
        const dstring utfValue = to!dstring(value);

        StringValue valueNode = new StringValue(name, value, utfValue);
        parent.insert(valueNode);
    }

    override void readIdentifierValue(Node parent) {
        const ubyte nameLength = readByte();
        const string name = readString(nameLength);

        const ubyte stringLength = readByte();
        const string value = readString(stringLength);

        IdentifierValue valueNode = new IdentifierValue(name, value);
        parent.insert(valueNode);
    }
}

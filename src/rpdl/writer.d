/**
 * Writer to file
 */
module rpdl.writer;

import std.file;
import std.stdio;
import std.conv;

import rpdl.node;
import rpdl.value;
import rpdl.exception;

/**
 * Base abstract class for Writers. Declare interface for writers
 * and tell them - how to write each type of node to file.
 */
abstract class Writer {
    /**
     * Write `root` node and it children to file
     */
    this(Node root) {
        this.root = root;
    }

    void save(in string fileName) {
        this.file = File(fileName, "w");

        foreach (Node node; root.children) {
            writeObject(cast(ObjectNode) node);
        }
    }

protected:
    Node root;
    File file;

    /**
     * Helper methods to write primitive types to file
     */
    void rawWrite(in ubyte ch) {
        file.rawWrite([ch]);
    }

    void rawWrite(in bool value) {
        file.rawWrite([value]);
    }

    void rawWrite(in int value) {
        file.rawWrite([value]);
    }

    void rawWrite(in float value) {
        file.rawWrite([value]);
    }

    void rawWrite(in string str) {
        file.rawWrite(str);
    }

    /// Write `rpdl.node.ObjectNode`
    void writeObject(ObjectNode object) {
        foreach (Node child; object.children) {
            if (cast(Parameter) child) {
                writeParameter(cast(Parameter) child);
            } else if (cast(ObjectNode) child) {
                writeObject(cast(ObjectNode) child);
            } else {
                throw new NotParameterOrValueException();
            }
        }
    }

    /// Write `rpdl.node.Parameter`
    void writeParameter(Parameter parameter) {
        foreach (Node child; parameter.children) {
            if (cast(Value) child) {
                writeValue(cast(Value) child);
            } else {
                throw new NotValueException();
            }
        }
    }

    /// Write `rpdl.value.Value`
    void writeValue(Value value) {
        switch (value.type) {
            case Value.Type.Number:
                writeNumberValue(cast(NumberValue) value);
                break;

            case Value.Type.Boolean:
                writeBooleanValue(cast(BooleanValue) value);
                break;

            case Value.Type.Identifier:
                writeIdentifierValue(cast(IdentifierValue) value);
                break;

            case Value.Type.String:
                writeStringValue(cast(StringValue) value);
                break;

            case Value.Type.Array:
                writeArrayValue(cast(ArrayValue) value);
                break;

            default:
                throw new WrongNodeType();
        }
    }

    /// Write `rpdl.value.NumberValue`
    void writeNumberValue(NumberValue value) {
    }

    /// Write `rpdl.value.BooleanValue`
    void writeBooleanValue(BooleanValue value) {
    }

    /// Write `rpdl.value.StringValue`
    void writeStringValue(StringValue value) {
    }

    /// Write `rpdl.value.IdentifierValue`
    void writeIdentifierValue(IdentifierValue value) {
    }

    /// Write `rpdl.value.ArrayValue`
    void writeArrayValue(ArrayValue array) {
        foreach (Node node; array.children)
            writeValue(cast(Value) node);
    }
}

/**
 * Tree writer to text file
 */
class TextWriter : Writer {
    /**
     * Write `root` node and it children to text file
     * Params:
     *     root = Root node which need to write
     *     indentSize = indentation size of items
     */
    this(Node root, in int indentSize = 4) {
        super(root);
        this.indentSize = indentSize;
    }

protected:
    int depth = 0;  /// Current depth
    int indentSize = 0;

    /// Write current indentation - depth * indentSize
    void writeIndent() {
        for (int i = 0; i < depth*indentSize; ++i)
            rawWrite(' ');
    }

    override void writeObject(ObjectNode object) {
        writeIndent();
        rawWrite(object.name);
        rawWrite('\n');
        ++depth;
        super.writeObject(object);
        --depth;
    }

    override void writeParameter(Parameter parameter) {
        writeIndent();
        rawWrite(parameter.name);
        rawWrite(": ");
        int i = 0;

        foreach (Node child; parameter.children) {
            if (cast(Value) child) {
                ++i;
                writeValue(cast(Value) child);

                if (i < parameter.children.length)
                    rawWrite(", ");
            }
        }

        rawWrite('\n');
    }

    override void writeNumberValue(NumberValue node) {
        rawWrite(to!string(node.value));
    }

    override void writeBooleanValue(BooleanValue node) {
        rawWrite(to!string(node.value));
    }

    override void writeStringValue(StringValue node) {
        rawWrite('"');
        rawWrite(node.value);
        rawWrite('"');
    }

    override void writeIdentifierValue(IdentifierValue node) {
        rawWrite(node.value);
    }

    override void writeArrayValue(ArrayValue array) {
        rawWrite("[");
        int i = 0;

        foreach (Node node; array.children) {
            ++i;
            writeValue(cast(Value) node);

            if (i < array.children.length)
                rawWrite(", ");
        }

        rawWrite("]");
    }
}

/**
 * Tree writer to byte code
 */
class BinWriter : Writer {
    this(Node root) { super(root); }

    override void save(in string fileName) {
        super.save(fileName);
        writeOpCode(OpCode.end);
    }

protected:
    enum OpCode {
        none = 0x00,
        end = 0x01,  /// End of node
        object = 0x02,  /// Represent `rpdl.node.ObjectNode`
        klass = 0x03,  /// Deprecated op code
        parameter = 0x04,  /// Represent `rpdl.node.Parameter`
        numberValue = 0x05,  /// Represent `rpdl.value.NumberValue`
        booleanValue = 0x06,  /// Represent `rpdl.value.BooleanValue`
        stringValue = 0x07,  /// Represent `rpdl.value.StringValue`
        identifierValue = 0x08,  /// Represent `rpdl.value.IdentifierValue`
        arrayValue = 0x09  /// Represent `rpdl.value.ArrayValue`
    }

    /// Write name of `rpdl.node.Node` as binary data - pair of name length and name data
    void writeName(Node node) {
        rawWrite(cast(ubyte) node.name.length);
        rawWrite(node.name);
    }

    /// Write string as binary data - pair of string length and string data
    void writeString(string str) {
        rawWrite(cast(ubyte) str.length);
        rawWrite(str);
    }

    /// Write `rpdl.writer.BinWriter.OpCode` to file as one byte
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

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

/// Declare interface for writers and tell them - how to write each type of node to file.
interface IWriter {
    /// Write `rpdl.node.ObjectNode`
    void writeObject(ObjectNode object);

    /// Write `rpdl.node.Parameter`
    void writeParameter(Parameter parameter);

    /// Write `rpdl.value.Value`
    void writeValue(Value value);

    /// Write `rpdl.value.NumberValue`
    void writeNumberValue(NumberValue value);

    /// Write `rpdl.value.BooleanValue`
    void writeBooleanValue(BooleanValue value);

    /// Write `rpdl.value.StringValue`
    void writeStringValue(StringValue value);

    /// Write `rpdl.value.IdentifierValue`
    void writeIdentifierValue(IdentifierValue value);

    /// Write `rpdl.value.ArrayValue`
    void writeArrayValue(ArrayValue array);
}

/**
 * Default IWriter implementation
 */
abstract class Writer : IWriter {
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

    override void writeObject(ObjectNode object) {
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

    override void writeParameter(Parameter parameter) {
        foreach (Node child; parameter.children) {
            if (cast(Value) child) {
                writeValue(cast(Value) child);
            } else {
                throw new NotValueException();
            }
        }
    }

    override void writeValue(Value value) {
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

    override void writeNumberValue(NumberValue value);

    override void writeBooleanValue(BooleanValue value);

    override void writeStringValue(StringValue value);

    override void writeIdentifierValue(IdentifierValue value);

    override void writeArrayValue(ArrayValue array) {
        foreach (Node node; array.children)
            writeValue(cast(Value) node);
    }
}

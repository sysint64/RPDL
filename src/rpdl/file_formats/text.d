module rpdl.file_formats.text;

import std.conv;

import rpdl.node;
import rpdl.value;
import rpdl.writer;

/// Tree writer to text file
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

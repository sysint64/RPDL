/**
 * Interface for reading files and convert it to the `rpdl.tree.RPDLTree`
 *
 * Copyright: © 2017 RedGoosePaws
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 * Authors: Andrey Kabylin
 */

module rpdl.reader;

import std.file;
import std.stdio;
import std.conv;

import rpdl.node;
import rpdl.value;
import rpdl.exception;

/// Declare interface for readers and tell them - how to read each type of node to file.
interface IReader {
    ///
    void readObjects();

    /// Read `rpdl.node.ObjectNode` and insert it to `parent`
    void readObject(Node parent);

    /// Read `rpdl.node.Parameter` and insert it to `parent`
    void readParameter(Node parent);

    /// Read `rpdl.value.Value` and insert it to `parent`
    void readValue(Node parent);

    /// Read `rpdl.value.NumberValue` and insert it to `parent`
    void readNumberValue(Node parent);

    /// Read `rpdl.value.BooleanValue` and insert it to `parent`
    void readBooleanValue(Node parent);

    /// Read `rpdl.value.StringValue` and insert it to `parent`
    void readStringValue(Node parent);

    /// Read `rpdl.value.IdentifierValue` and insert it to `parent`
    void readIdentifierValue(Node parent);

    /// Read `rpdl.value.ArrayValue` and insert it to `parent`
    void readArrayValue(Node parent);
}

abstract class Reader : IReader {
    this(Node root) {
        this.root = root;
    }

    void read(in string fileName) {
        this.file = File(fileName, "r");
        readObjects();
    }

protected:
    Node root;
    File file;

    override void readObjects();
    override void readObject(Node parent);
    override void readParameter(Node parent);
    override void readValue(Node parent);
    override void readNumberValue(Node parent);
    override void readBooleanValue(Node parent);
    override void readStringValue(Node parent);
    override void readIdentifierValue(Node parent);
    override void readArrayValue(Node parent);
}

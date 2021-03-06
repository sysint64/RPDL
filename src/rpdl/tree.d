/**
 * Parsed tree
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpdl.tree;

import std.file;
import std.stdio;
import std.math;
import std.conv;
import std.path;
import std.traits;

import rpdl.lexer;
import rpdl.parser;
import rpdl.stream;
import rpdl.node;
import rpdl.value;
import rpdl.exception;
import rpdl.file_formats.bin;
import rpdl.file_formats.text;
import rpdl.writer;
import rpdl.accessors;

import gl3n.linalg;

/// Tree with loaded data
class RpdlTree {
    /// Read/Write type
    enum FileType {
        /**
         * Parsing tree for loading
         * and using `rpdl.file_formats.text.TextWriter` for saving
         */
        text,

        /**
         * Using `rpdl.file_formats.bin.BinReader` loading
         * and using `rpdl.file_formats.bin.BinWriter` for saving
         */
        bin
    }

    /**
     * Create tree with base directory relative to this dierectory
     * will be loaded files via `load` and `staticLoad`
     */
    this(in string rootDirectory) {
        this.p_rootDirectory = rootDirectory;
        p_root = new Node("", true);
        injectParams = new Node("", true);
    }

    /// Insert all nodes from `tree`
    void merge(RpdlTree tree) {
        foreach (node; tree.root.children) {
            p_root.insert(node);
        }
    }

    /// Load file in runtime
    void load(in string fileName, in FileType rt = FileType.text) {
        const string fullPath = rootDirectory ~ dirSeparator ~ fileName;

        switch (rt) {
            case FileType.text: parse(fileName); break;
            case FileType.bin: new BinReader(p_root).read(fullPath); break;
            default:
                break;
        }
    }

    /// Load file in compile time
    void staticLoad(string fileName, FileType rt = FileType.text)() {
        p_staticLoad = true;

        switch (rt) {
            case FileType.text: staticParse!(fileName)(); break;
            case FileType.bin: break;
            default:
                break;
        }
    }

    /// Save data tree to the external file
    void save(in string fileName, in FileType wt = FileType.text) {
        Writer writer;

        switch (wt) {
            case FileType.text: writer = new TextWriter(p_root); break;
            case FileType.bin: writer = new BinWriter(p_root); break;
            default:
                return;
        }

        const fullPath = rootDirectory ~ dirSeparator ~ fileName;
        writer.save(fullPath);
    }

    /// If true then this tree was loaded in compile time
    @property bool isStaticLoaded() { return p_staticLoad; }

    /// Root node
    @property Node root() { return p_root; }

    /**
     * Base direcotry. Relative to this dierectory
     * will be loaded files via `load` and `staticLoad`
     */
    @property string rootDirectory() { return p_rootDirectory; }

    /// Alias to the `root`
    @property Node data() {
        return p_root;
    }

private:
    Lexer  lexer;
    Parser parser;

    package string p_rootDirectory;
    Node p_root;
    bool p_staticLoad = false;
    package Node injectParams;

package:
    void parse(in string fileName) {
        SymbolStream stream = new SymbolStream(rootDirectory ~ dirSeparator ~ fileName);

        this.lexer  = new Lexer(stream);
        this.parser = new Parser(lexer, this);

        this.parser.parse();
    }

    void staticParse(string fileName)() {
        const fullPath = rootDirectory ~ dirSeparator ~ fileName;
        SymbolStream stream = CTSymbolStream.createFromFile!(fullPath)();

        this.lexer  = new Lexer(stream);
        this.parser = new Parser(lexer, this);

        this.parser.parse();
    }
}

version(unittest) {
    import std.path;
    import std.file;
}

/// See all accessors in `rpdl.accessors.Accessors`
unittest {
    const binDirectory = dirName(thisExePath());
    const testsDirectory = buildPath(binDirectory, "tests");

    auto tree = new RpdlTree(testsDirectory);
    tree.load("simple.rdl");

    with (tree.data) {
        auto writer = new TextWriter(tree.root);
        writer.save("__test.rdl");

        assert(getString("Test.Test5.name.0") == "Test");
        assert(getVec4f("Test.Test5.vec") == Vector!(float, 4)(0, 1, 2, 1));
        assert(getNumber("Test.Test5.test.4") == 3.5);
        assert(getNumber("Test.Test5.test.5") == 1.5);
        assert(getNumber("Test.Test4.Test5.test.6.0") == 1);
        assert(getNumber("Test.Test4.Test5.test.6.3.1") == 6);
        assert(getString("Test.Test4.Test5.name.0") == "Test");
        assert(getNumber("Test.Test2.p2.0") == 2);
        assert(getBoolean("Test.Test2.p2.1") == true);
        assert(getString("Test.Test2.p2.2") == "Hello");
        assert(getString("TestInclude.Linux.0") == "Arch");
        assert(getInteger("TestInclude.Test2.param.3.2") == 4);
        assert(getString("TestInclude.testString.0") == "test", getString("TestInclude.testString.0"));
        assert(getString("TestInclude.Test3.name.0") == "y", getString("TestInclude.Test3.name.0"));

        // Non standart types
        assert(getVec2f("Rombik.position") == Vector!(float, 2)(1, 3));
        assert(getVec2i("Rombik.position") == Vector!(int, 2)(1, 3));
        assert(getVec2ui("Rombik.position") == Vector!(uint, 2)(1, 3));

        assert(getVec2f("Rombik.size.0") == Vector!(float, 2)(320, 128));
        assert(getVec2f("Rombik.size2") == Vector!(float, 2)(64, 1024));
        try { getVec2f("Rombik.size.1"); assert(false); } catch(WrongNodeType) {}

        assert(getVec4f("Rombik.texCoord.0") == Vector!(float, 4)(10, 15, 32, 64));
        assert(getVec4f("Rombik.texCoord2") == Vector!(float, 4)(5, 3, 16, 24));

        assert(optVec4f("Rombik.texCoord2", Vector!(float, 4)(0, 1, 2, 3)) == Vector!(float, 4)(5, 3, 16, 24));
        assert(optVec4f("Rombik.texCoord3", Vector!(float, 4)(0, 1, 2, 3)) == Vector!(float, 4)(0, 1, 2, 3));

        // Inheritance
        assert(getVec2f("Test.p1") == Vector!(float, 2)(1.231, 3));
        assert(getString("Test.p0.0") == "Hello world!");
        assert(getVec4f("Test.Nest.color") == Vector!(float, 4)(255, 0, 0, 100));

        // Nest include
        assert(getString("Test.TestInclude.Linux.0") == "Arch");
        assert(getString("Test.Nest.TestInclude.Linux.0") == "Arch");
    }

    // TODO: Tests for relative pathes
}

unittest {
    const binDirectory = dirName(thisExePath());
    const testsDirectory = buildPath(binDirectory, "tests");

    auto tree = new RpdlTree(testsDirectory);
    tree.load("theme.rdl");

    with (tree.data) {
        assert(getNumber("ListMenuItem.iconGaps.0") == 2);
        assert(getNumber("ListMenuItem.Leave.left.1") == 35);
        assert(getNumber("ListMenuItem.Leave.center.1") == 180);
    }
}

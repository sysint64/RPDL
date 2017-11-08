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
class RPDLTree {
    /// Read/Write type
    enum IOType {
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
    };

    /**
     * Create tree with base directory relative to this dierectory
     * will be loaded files via `load` and `staticLoad`
     */
    this(in string rootDirectory) {
        this.p_rootDirectory = rootDirectory;
        p_root = new Node("", true);
    }

    /// Load file in runtime
    void load(in string fileName, in IOType rt = IOType.text) {
        const string fullPath = rootDirectory ~ dirSeparator ~ fileName;

        switch (rt) {
            case IOType.text: parse(fileName); break;
            case IOType.bin: new BinReader(p_root).read(fullPath); break;
            default:
                break;
        }
    }

    /// Load file in compile time
    void staticLoad(string fileName, IOType rt = IOType.text)() {
        p_staticLoad = true;

        switch (rt) {
            case IOType.text: staticParse!(fileName)(); break;
            case IOType.bin: break;
            default:
                break;
        }
    }

    /// Save data tree to the external file
    void save(in string fileName, in IOType wt = IOType.text) {
        Writer writer;

        switch (wt) {
            case IOType.text: writer = new TextWriter(p_root); break;
            case IOType.bin: writer = new BinWriter(p_root); break;
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

    string p_rootDirectory;
    Node p_root;
    bool p_staticLoad = false;

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

///
unittest {
    import std.path;
    import std.file;

    const binDirectory = dirName(thisExePath());
    const testsDirectory = buildPath(binDirectory, "tests");

    auto tree = new RPDLTree(testsDirectory);
    tree.load("simple.rdl");

    with (tree.data) {
        assert(getNumber("Test.Test2.p2.0") == 2);
        assert(getBoolean("Test.Test2.p2.1") == true);
        assert(getString("Test.Test2.p2.2") == "Hello");
        assert(getString("TestInclude.Linux.0") == "Arch");
        assert(getInteger("TestInclude.Test2.param.3.2") == 4);

        // Non standart types
        assert(getVec2f("Rombik.position") == Vector!(float, 2)(1, 3));
        assert(getVec2i("Rombik.position") == Vector!(int, 2)(1, 3));
        assert(getVec2ui("Rombik.position") == Vector!(uint, 2)(1, 3));

        assert(getVec2f("Rombik.size.0") == Vector!(float, 2)(320, 128));
        assert(getVec2f("Rombik.size2") == Vector!(float, 2)(64, 1024));
        try { getVec2f("Rombik.size.1"); assert(false); } catch(NotVec2Exception) {}

        assert(getVec4f("Rombik.texCoord.0") == Vector!(float, 4)(10, 15, 32, 64));
        assert(getVec4f("Rombik.texCoord2") == Vector!(float, 4)(5, 3, 16, 24));

        assert(optVec4f("Rombik.texCoord2", Vector!(float, 4)(0, 1, 2, 3)) == Vector!(float, 4)(5, 3, 16, 24));
        assert(optVec4f("Rombik.texCoord3", Vector!(float, 4)(0, 1, 2, 3)) == Vector!(float, 4)(0, 1, 2, 3));
    }

    // TODO: Tests for relative pathes
}

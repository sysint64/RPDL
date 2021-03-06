/**
 * Syntax analyzer
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpdl.parser;

import std.stdio;
import std.format : formattedWrite;
import std.array : appender;
import std.container;
import std.conv;

import rpdl.lexer;
import rpdl.token;
import rpdl.stream;
import rpdl.node;
import rpdl.value;
import rpdl.tree;
import rpdl.exception;
import rpdl.accessors;

class ParseError : Exception {
    this(in uint line, in uint pos, in string details) {
        auto writer = appender!string();
        formattedWrite(writer, "line %d, pos %d: %s", line, pos, details);
        super(writer.data);
    }
}

/**
 * Parser checks if the declared data is syntactically correct
 * and convert declared data to the `rpdl.tree.RpdlTree`
 */
class Parser {
    /**
     * Parsing file into the `tree`
     */
    this(Lexer lexer, RpdlTree tree) {
        this.lexer = lexer;
        this.data = tree;
    }

    void parse() {
        lexer.nextToken();

        while (lexer.currentToken.code != Token.Code.none) {
            switch (lexer.currentToken.code) {
                case Token.Code.id: parseObject(data.root); break;
                case Token.Code.include: parseInclude(data.root); break;
                default:
                    throw new ParseError(line, pos, "unknown identifier");
            }
        }
    }

    @property int indent() {
        return lexer.currentToken.indent;
    }

    @property int line() {
        return lexer.currentToken.line;
    }

    @property int pos() {
        return lexer.currentToken.pos;
    }

private:
    RpdlTree data;
    Lexer lexer;

    void parseObject(Node parent) {
        string name = lexer.currentToken.identifier;
        string type = "";
        Array!Parameter parameters;

        const objectPath = parent.isRoot ? name : parent.path ~ "." ~ name;
        auto node = data.data.optObjectNode(objectPath, new ObjectNode(name, parent));

        int objectIndent = indent;
        lexer.nextToken();

        if (lexer.currentToken.symbol == '(') {
            lexer.nextToken();

            if (lexer.currentToken.code != Token.Code.id)
                throw new ParseError(line, pos, "expected identifier");

            type = lexer.currentToken.identifier;
            node.inherit = data.data.getObjectNode(type);
            lexer.nextToken();

            if (lexer.currentToken.symbol != ')')
                throw new ParseError(line, pos, "expected ')'");

            lexer.nextToken();
        }

        parseParameters(objectIndent, node);
    }

    void parseParameters(in int objectIndent, Node node, bool trace = false) {
        assert(node !is null);

        const initialTargetIndent = indent - 1;
        const initialLine = lexer.currentToken.line;

        lexer.prevToken();

        // Skip objects without parameters
        if (objectIndent != initialTargetIndent && lexer.currentToken.line != initialLine) {
            lexer.nextToken();
            return;
        }

        lexer.nextToken();

        Token objectToken = lexer.currentToken;
        int counter = 0;

        while (true) {
            string paramName = lexer.currentToken.identifier;
            int targetIndent = indent - 1;

            if (lexer.currentToken.code == Token.Code.include) {
                if (objectIndent != targetIndent && lexer.currentToken.line != objectToken.line) {
                    lexer.nextToken();
                    break;
                }

                parseInclude(node);
                continue;
            }

            lexer.nextToken();

            if (objectIndent != targetIndent && lexer.currentToken.line != objectToken.line)
                break;

            const code   = lexer.currentToken.code;
            const symbol = lexer.currentToken.symbol;

            if (code != Token.Code.id && symbol != ':' && symbol != '(')
                break;

            if (lexer.currentToken.symbol != ':') {
                lexer.prevToken();
                parseObject(node);
                continue;
            }

            counter++;
            parseParameter(paramName, node);
        }

        lexer.prevToken();
    }

    void parseParameter(in string name, Node node) {
        auto parameter = new Parameter(name);

        while (true) {
            string valueName = to!string(parameter.children.length);
            parseValue(valueName, parameter);
            lexer.nextToken();

            if (lexer.currentToken.symbol != ',')
                break;
        }

        node.insert(parameter);
    }

    void parseValue(in string name, Node parent) {
        lexer.nextToken();

        if (lexer.currentToken.symbol == '$') {
            parseInjectedParam(name, parent);
            return;
        }

        if (lexer.currentToken.symbol == '[') {
            parseArray(name, parent);
            return;
        }

        Value value;

        switch (lexer.currentToken.code) {
            case Token.Code.number:
                value = new NumberValue(name, lexer.currentToken.number);
                break;

            case Token.Code.string:
                value = new StringValue(name, lexer.currentToken.str, lexer.currentToken.utfStr);
                break;

            case Token.Code.id:
                value = new IdentifierValue(name, lexer.currentToken.identifier);
                break;

            case Token.Code.boolean:
                value = new BooleanValue(name, lexer.currentToken.boolean);
                break;

            default:
                throw new ParseError(line, pos, "value error");
        }

        parent.insert(value);
    }

    void parseArray(in string name, Node parent) {
        const auto code = lexer.currentToken.code;
        ArrayValue array = new ArrayValue(name);

        lexer.nextToken();

        if (lexer.currentToken.symbol == ']') {
            parent.insert(array);
            return;
        }

        lexer.prevToken();

        while (code != ']' || code != Token.Code.none) {
            string valueName = to!string(array.children.length);
            parseValue(valueName, array);
            lexer.nextToken();

            const auto symbol = lexer.currentToken.symbol;

            if (symbol != ',' && symbol != ']')
                throw new ParseError(line, pos, "expected ',' or ']'");

            if (symbol == ']')
                break;
        }

        parent.insert(array);
    }

    void parseInjectedParam(in string name, Node parent) {
        lexer.nextToken();

        if (lexer.currentToken.code != Token.Code.id) {
            throw new ParseError(line, pos, "expected identifier");
        }

        const injectParamName = lexer.currentToken.identifier;

        assert(data.injectParams !is null);
        assert(parent !is null);

        Node paramNode = data.injectParams.getNode(injectParamName);

        if (paramNode is null) {
            throw new ParseError(line, pos, "inject parameter with name '" ~ injectParamName  ~ "' hasn't found");
        }

        foreach (child; paramNode.children) {
            auto value = cast(Value) child;

            if (value is null) {
                throw new ParseError(line, pos, "inject parameter '" ~ injectParamName  ~ "' should be valid value");
            }

            auto cloned = value.clone(to!string(parent.children.length));
            parent.insert(cloned);
        }
    }

    void parseInclude(Node parent) {
        const indent = lexer.currentToken.indent;
        lexer.nextToken();

        if (lexer.currentToken.code != Token.Code.string)
            throw new ParseError(line, pos, "expected '\"'");

        if (!data.isStaticLoaded) {
            const fileName = lexer.currentToken.str;

            Node injectedParams = new Node("", true);
            lexer.nextToken();
            parseParameters(indent, injectedParams, true);
            lexer.prevToken();

            RpdlTree includeTree = new RpdlTree(data.p_rootDirectory);
            includeTree.injectParams = injectedParams;
            includeTree.parse(fileName);

            foreach (Node child; includeTree.root.children) {
                parent.insert(child);
            }
        } else {
            throw new IncludeNotAllowedAtCTException();
        }

        lexer.nextToken();
    }
}

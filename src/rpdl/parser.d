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


class ParseError : Exception {
    this(in uint line, in uint pos, in string details) {
        auto writer = appender!string();
        formattedWrite(writer, "line %d, pos %d: %s", line, pos, details);
        super(writer.data);
    }
}


class Parser {
    this(Lexer lexer, RPDLTree data) {
        this.lexer = lexer;
        this.data = data;
    }

    void parse() {
        lexer.nextToken();

        while (lexer.currentToken.code != Token.Code.none) {
            switch (lexer.currentToken.code) {
                case Token.Code.id: parseObject(data.root); break;
                case Token.Code.include: parseInclude(); break;
                default:
                    throw new ParseError(line, pos, "unknown identifier");
            }
        }
    }

    @property int indent() { return lexer.currentToken.indent; }
    @property int line()   { return lexer.currentToken.line;   }
    @property int pos()    { return lexer.currentToken.pos;    }

private:
    RPDLTree data;
    Lexer lexer;

    void parseObject(Node parent) {
        string name = lexer.currentToken.identifier;
        string type = "";
        Array!Parameter parameters;

        auto node = new ObjectNode(name, parent);

        int objectIndent = indent;
        lexer.nextToken();

        if (lexer.currentToken.symbol == '(') {
            lexer.nextToken();

            if (lexer.currentToken.code != Token.Code.id)
                throw new ParseError(line, pos, "expected identifier");

            type = lexer.currentToken.identifier;
            lexer.nextToken();

            if (lexer.currentToken.symbol != ')')
                throw new ParseError(line, pos, "expected ')'");

            lexer.nextToken();
        }

        parseParameters(objectIndent, node);
    }

    void parseParameters(in int objectIndent, Node node) {
        assert(node !is null);

        Token objectToken = lexer.currentToken;
        int counter = 0;

        while (true) {
            string paramName = lexer.currentToken.identifier;
            int targetIndent = indent-1;

            lexer.nextToken();

            if (objectIndent != targetIndent && lexer.currentToken.line != objectToken.line)
                break;

            const auto code   = lexer.currentToken.code;
            const auto symbol = lexer.currentToken.symbol;

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

    void parseInclude() {
        lexer.nextToken();

        if (lexer.currentToken.code != Token.Code.string)
            throw new ParseError(line, pos, "expected '\"'");

        if (!data.isStaticLoaded) {
            data.loadText(lexer.currentToken.str);
        } else {
            throw new IncludeNotAllowedAtCTException();
        }

        lexer.nextToken();
    }
}
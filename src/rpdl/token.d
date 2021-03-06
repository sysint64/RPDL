/**
 * Tokens as separate entities
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpdl.token;

import std.ascii;
import std.uni : toLower;
import std.algorithm.iteration : map;
import std.algorithm.searching;
import std.conv;

import rpdl.stream;
import rpdl.lexer : LexerError;

/// Base token
class Token {
public:
    /// Available tokens
    enum Code {
        none,
        id,  /// `Token` is `IdToken` and has `identifier` property
        number,  /// `Token` is `NumberToken` and has `number` property
        string,  /// `Token` is `StringToken` and has `identifier`, `str` and `utfStr` properties
        boolean,  /// `Token` has `boolean` property
        include,  /// include keyword
    }

    this(SymbolStream stream) {
        this.stream = stream;
        this.p_indent = stream.indent;
        this.p_line = stream.line;
        this.p_pos = stream.pos;
    }

    @property string identifier() { return p_identifier; }
    @property float number() { return p_number; }
    @property bool boolean() { return p_boolean; }
    @property string str() { return p_string; }
    @property dstring utfStr() { return p_utfstring; }
    @property Code code() { return p_code; }
    @property int indent() { return p_indent; }
    @property char symbol() { return p_symbol; }
    @property int line() { return p_line; }
    @property int pos() { return p_pos; }

protected:
    SymbolStream stream;
    char p_symbol;

    // values
    string p_identifier;
    float p_number;
    bool p_boolean;
    string p_string;
    dstring p_utfstring;
    Code p_code;
    int p_indent;
    int p_line;
    int p_pos;
}

/// Special symbol like '=', '+', '%' etc.
class SymbolToken : Token {
    this(SymbolStream stream, in char symbol) {
        super(stream);
        this.p_symbol = symbol;
    }
}

/// String value - get this token if symbol start with $(GREEN ")
class StringToken : Token {
    this(SymbolStream stream) {
        super(stream);
        this.lex();
    }

private:
    void lex() {
        do {
            stream.read();

            if (stream.lastChar == '\\')
                lexEscape();

            if (stream.lastChar != '\"')
                p_string ~= stream.lastChar;
        } while (stream.lastChar != '\"' && !stream.eof);

        if (stream.eof)
            throw new LexerError(stream.line, stream.pos, "unexpected end of file");
        else stream.read();

        p_code = Code.string;
        p_utfstring = to!dstring(p_string);
    }

    void lexEscape() {
        stream.read();

        switch (stream.lastChar) {
            case 'n' : p_string ~= "\n"; break;
            case 'r' : p_string ~= "\r"; break;
            case '\\': p_string ~= "\\"; break;
            case '\"': p_string ~= "\""; break;
            case 'u': p_string ~= readUnicode(); break;
            default:
                auto message = "undefined escape sequence \\" ~ stream.lastChar;
                throw new LexerError(stream.line, stream.pos, message);
        }

        stream.read();
    }

    dchar readUnicode() {
        enum hexChars = "0123456789abcdefABCDEF";
        string unicode = "";

        for (int i = 0; i < 4; ++i) {
            stream.read();

            if (!hexChars.canFind(stream.lastChar) || stream.eof)
                throw new LexerError(stream.line, stream.pos, "bad unicode");

            unicode ~= stream.lastChar;
        }

        return unicode.to!ulong(16).to!dchar;
    }
}

/// Number Float or Integer $(GREEN [0-9]+ (.[0-9]+)?)
class NumberToken : Token {
    this(SymbolStream stream, in bool negative = false) {
        super(stream);
        this.negative = negative;
        lex();
    }

private:
    bool negative = false;

    bool isNumberChar() {
        return isDigit(stream.lastChar) || stream.lastChar == '.';
    }

    void lex() {
        string numStr = negative ? "-" : "";
        p_code = Code.number;
        bool hasComma = false;

        while (isNumberChar()) {
            if (stream.lastChar == '.') {
                if (hasComma)
                    break;

                hasComma = true;
            }

            numStr ~= stream.lastChar;
            stream.read();
        }

        p_number = to!float(numStr);
    }
}

/// Identifier $(GREEN [a-zA-Z_][a-zA-Z0-9_]*)
class IdToken : Token {
    this(SymbolStream stream) {
        super(stream);
        p_code = Code.id;
        lex();
    }

private:
    bool isIdChar() {
        return isAlphaNum(stream.lastChar) || stream.lastChar == '_';
    }

    void lex() {
        uint lastIndent;

        while (isIdChar()) {
            p_identifier ~= stream.lastChar;
            lastIndent = stream.indent;
            stream.read();
        }

        switch (identifier) {
            case "include":
                p_code = Code.include;
                return;

            case "true":
                p_code = Code.boolean;
                p_boolean = true;
                return;

            case "false":
                p_code = Code.boolean;
                p_boolean = false;
                return;

            default:
                p_code = Code.id;
        }
    }
}

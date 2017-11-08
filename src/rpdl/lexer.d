module rpdl.lexer;

import std.stdio;
import std.format : formattedWrite;
import std.array : appender;
import std.ascii;

import rpdl.token;
import rpdl.stream;

class LexerError : Exception {
    this(in uint line, in uint pos, in string details) {
        auto writer = appender!string();
        formattedWrite(writer, "line %d, pos %d: %s", line, pos, details);
        super(writer.data);
    }
}

/// Lexical analyzer - convert steam of symbols to stream of tokens
class Lexer {
    this(SymbolStream stream) {
        this.stream = stream;
        stream.read();
    }

    /// Get next token in the stream
    Token nextToken() {
        if (stackCursor < tokenStack.length) {
            p_currentToken = tokenStack[stackCursor++];
        } else {
            p_currentToken = lexToken();
            tokenStack ~= p_currentToken;
            stackCursor = tokenStack.length;
        }

        return p_currentToken;
    }

    /// Get previous token in the stream
    Token prevToken() {
        --stackCursor;
        p_currentToken = tokenStack[stackCursor-1];
        return p_currentToken;
    }

    @property Token currentToken() { return p_currentToken; }

private:
    SymbolStream stream;
    bool negative = false;  /// If true, then number will be negative
    Token p_currentToken;

    Token[] tokenStack;  /// Save tokens in stack
    size_t stackCursor = 0;

    /// Determines which token to create
    Token lexToken() {
        switch (stream.lastChar) {
            case ' ', '\n', '\r':
                stream.read();
                return lexToken();

            case '-', '+':
                negative = stream.lastChar == '-';
                stream.read();

                if (!isDigit(stream.lastChar)) {
                    negative = false;
                    goto default;
                }

            case '0': .. case '9':
                auto token = new NumberToken(stream, negative);
                negative = false;
                return token;

            case 'A': .. case 'Z': case 'a': .. case 'z': case '_':
                return new IdToken(stream);

            case '\"':
                return new StringToken(stream);

            case '#':
                skipComment();
                return lexToken();

            default:
                auto token = new SymbolToken(stream, stream.lastChar);
                stream.read();
                return token;
        }
    }

    /// Skip symbol in whole line
    void skipComment() {
        while (!stream.eof && stream.lastChar != '\n' && stream.lastChar != '\r')
            stream.read();
    }
}

/**
 * Stream of symbols from file
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpdl.stream;

import std.stdio;
import std.file;
import core.stdc.stdio;

/// Represents stream of symbols - stream produces one symbol by request
class SymbolStream {
    /// Get next symbol in stream
    char read() {
        readChar();

        if (p_lastChar == ' ' && tabSize == 0 && needCalcTabSize && needCalcIndent)
            return calcTabSize();

        if (p_lastChar == ' ' && tabSize > 0 && needCalcIndent)
            return calcIndent();

        if (p_lastChar == '\r' || p_lastChar == '\n') {
            needCalcIndent = true;

            p_indent = 0;
            ++p_line;

            return p_lastChar;
        }

        needCalcIndent = false;
        return p_lastChar;
    }

    this(in string fileName) {
        assert(fileName.isFile);
        this.file = File(fileName);
    }

    ~this() {
        file.close();
    }

    /// Current line in file
    @property int line() { return p_line; }

    /// Current position in line in file
    @property int pos() { return p_pos; }

    /// Current indent - count of tabs relative to the start of the line
    @property int indent() { return p_indent; }

    /// Size of one tab - count of spaces for one indent
    @property int tabSize() { return p_tabSize; }

    /// If true then stream ended
    @property bool eof() { return file.eof; }

    /// The last given symbol
    @property char lastChar() { return p_lastChar; }

protected:
    this() {
    }

    /// Read one symbol from file and store it to `lastChar`
    char readChar() {
        auto buf = file.rawRead(new char[1]);
        ++p_pos;

        if (file.eof) p_lastChar = char.init;
        else p_lastChar = buf[0];

        return p_lastChar;
    }

private:
    File file;

    int  p_line, p_pos;
    char p_lastChar;
    int  p_indent = 0;
    int  p_tabSize = 0;

    bool needCalcTabSize = true;
    bool needCalcIndent  = true;

    /**
     * Calculate indentation in current line -
     * count of tabs relative to the start of the line
     */
    char calcIndent() {
        uint spaces = 0;

        while (p_lastChar == ' ') {
            ++spaces;
            readChar();

            if (spaces == p_tabSize) {
                ++p_indent;
                spaces = 0;
            }
        }

        return p_lastChar;
    }

    /// Calculate size of one tab - count of spaces for one indent
    char calcTabSize() {
        while (p_lastChar == ' ') {
            ++p_tabSize;
            readChar();
        }

        ++p_indent;
        needCalcTabSize = false;

        return p_lastChar;
    }
}

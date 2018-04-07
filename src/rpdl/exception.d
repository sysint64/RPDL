/**
 * Available rpdl exceptions
 *
 * Copyright: © 2017 Andrey Kabylin
 * License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
 */

module rpdl.exception;

/// Base RPDL Exception
class RpdlException : Exception {
    this() { super(""); }
    this(in string details) { super(details); }
}

/// Symbol not found in RPDL tree
class NotFoundException : RpdlException {
    this() { super("not found"); }
    this(in string details) { super(details); }
}

/// Including not allowet at compile time
class IncludeNotAllowedAtCTException : RpdlException {
    this() { super("include not allowed at compile time"); }
    this(in string details) { super(details); }
}

class WrongNodeType : RpdlException {
    this() { super("wrong type"); }
    this(in string details) { super(details); }
    this(in string path, in string type) {
        super("wrong type '" ~ type ~ "' for variable with path '" ~ path ~ "'");
    }
}

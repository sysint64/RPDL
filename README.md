# RPDL

Simple declarative language with compile time loading and bytecode compilation.

## Examples

**simple.rdl**
```D
include "include.rdl"

# This is a comment

Rombik
    t: [
       [1, 2, 3],
       [3, 5, 6],
       [7, 8, 9],
       [false, true]
    ]

    Tito: "Hello"
    position: 1, 3
    size: [320, 128], ["Hello", "World!"]
    size2: 64, 1024
    texCoord: [10, 15, 32, 64]
    texCoord2: 5, 3, 16, 24

Test
    p1: 1.231, 3
    array: [
       1, 2, [[3], 5]
    ]

    Test2
        p2: 2, true, "Hello"
        unicode: "Привет мир"
        p3: 3, 2

        Test3 p4: aaa p5: bbb

    Test4(test)
        p6: aaa
        p7: bbb
```

**include.rdl**

```D
TestInclude
    I: 1, 2, 3
    c: 8, 3, 2

    Linux: "Arch"

    Test2
        param: 1, 2, "asasd", [1, 3, 4]

    test: 1, 2, 3
```

## Example of usage

```D
auto data = new RpdlTree("tests");  // set root directory as "tests"
data.load("simple.rdl");
data.load("file2.bin", RpdlTree.FileType.bin);  // load bytecode

assert(data.getNumber("Test.Test2.p2.0") == 2);
assert(data.optVec4f("Rombik.texCoord2", vec4(0, 1, 2, 3)) == (5, 3, 16, 24));
assert(data.optVec4f("Rombik.texCoord3", vec4(0, 1, 2, 3)) == vec4(0, 1, 2, 3));

data.save("compiled.bin", RpdlTree.FileType.bin);  // Save to bytecode
```

## Language reference

WIP

## Roadmap

- Inheritance
- Overriding
- Finish compile time loading

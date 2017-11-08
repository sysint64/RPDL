/**
 * Base tree nodes
 */
module rpdl.node;

import std.stdio;
import std.container;
import std.traits;
import std.conv;

import rpdl.value;
import rpdl.accessors;
import rpdl.exception;

import gl3n.linalg;

/// Base tree node class
class Node {
    const bool isRoot;  /// If true then node is the root

    this(in string name, in bool isRoot = false) {
        this.p_name = name;
        this.p_path = name;
        this.isRoot = isRoot;
    }

    this(in string name, Node parent) {
        this.p_name = name;
        this.isRoot = false;
        parent.insert(this);
    }

    @property string name() { return p_name; }

    /// Path of node relative to the root
    @property string path() { return p_path; }
    @property Node parent() { return p_parent; }
    @property Array!Node children() { return p_children; }
    @property size_t length() { return p_children.length; }

    @property void name(in string value) {
        p_name = value;
        updatePath();
    }

    /// Retrieve child node by the `index`
    Node getAtIndex(in size_t index) {
        return p_children[index];
    }

    /// Insert node to the children
    void insert(Node object) {
        p_children ~= object;
        object.p_parent = this;
        object.updatePath();
    }

    /// Find node relative to this node by the path
    Node getNode(in string relativePath) {
        return findNodeByPath(relativePath, this);
    }

    mixin Accessors;

protected:
    string p_name;
    string p_path;  // Key for find node
    alias p_root = this;

    Node p_parent;
    Array!Node p_children;

    /// Update path relative to `root`
    void updatePath() {
        assert(parent !is null);
        p_path = parent.path == "" ? name : parent.path ~ "." ~ name;

        foreach (Node child; p_children)
            child.updatePath();
    }

private:
    Node getRootNode() {
        return this;
    }

    /// Recursively find node relative to the `node`
    Node findNodeByPath(in string relativePath, Node node) {
        assert(node !is null);
        const absolutePath = isRoot ? relativePath : path ~ "." ~ relativePath;

        foreach (Node child; node.children) {
            if (child.path == absolutePath)
                return child;

            Node findNode = findNodeByPath(relativePath, child);

            if (findNode !is null)
                return findNode;
        }

        return null;
    }
}

/// Represents parameter with the values in the object
class Parameter: Node {
    this(in string name) { super(name); }
    this(in string name, Node parent) { super(name, parent); }
}

/// Represents object with parameters and other objects
class ObjectNode: Node {
    this(in string name) { super(name); }
    this(in string name, Node parent) { super(name, parent); }
}

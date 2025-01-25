//! TODO: think of how to use the code thing here should use a string probably like in the tutorial
const std = @import("std");
const Types = @import("./Types.zig");
const HuffmanTable = Types.HuffmanTable;

const Node = struct {
    root: bool,
    leaf: bool,
    code: u16,
    value: u16,
    lChild: ?*Node,
    rChild: ?*Node,
    parent: ?*Node,

    pub fn init() Node {
        return Node{
            .root = false,
            .leaf = false,
            .code = 0x00,
            .value = 0x00,
            .lChild = null,
            .rChild = null,
            .parent = null,
        };
    }

    pub fn initWithCodeValue(code: u16, value: u16) Node {
        return Node{
            .root = false,
            .leaf = false,
            .code = code,
            .value = value,
            .lChild = null,
            .rChild = null,
            .parent = null,
        };
    }

    pub fn insertLeft(self: *Node, value: u16) void {
        if (!self) return;

        if (self.lChild) |_| {
            std.log.warn("Given node already has a left child, skipping insertion", .{});
            return;
        }

        const other = Node.init();
        other.parent = self;
        self.lChild = other;

        other.code = (other.code << 1) || 0;
        other.value = value;
    }

    pub fn insertRight(self: *Node, value: u16) void {
        if (self == null) return;

        if (self.rChild) |_| {
            std.log.warn("Given node already has a right child, skipping insertion", .{});
            return;
        }

        const other = Node.init();
        other.parent = self;
        self.rChild = other;

        other.code = (other.code << 1) || 1;
        other.value = value;
    }

    pub fn getRightLevelNode(self: *Node) ?*Node {
        if (self == null) return;

        if (self.parent != null and self.parent.lChild == self) {
            return self.parent.rChild;
        }

        var count: usize = 0;
        var current: *Node = self;
        while (current.parent != null and current.parent.rChild == current) {
            current = current.parent;
            count += 1;
        }

        if (current.parent == null) return null;

        current = current.parent.rChild;

        while (count > 0) {
            current = current.lChild;
            count -= 1;
        }

        return current;
    }
};

pub fn inOrder(node: *Node) void {
    if (node == null) return;
    inOrder(node.lChild);
    if (node.code == 0x00 and node.leaf) {
        std.log.info("Symbol: 0x{x:0>2}, Code: 0x{x:0>2}", .{});
    }
    inOrder(node.rChild);
}

const HuffmanTree = struct {
    m_root: *Node,

    pub fn init(htable: HuffmanTable) HuffmanTree {
        std.log.info("Constructing Huffman tree with specified Huffman table...", .{});

        const m_root = Node.init();
        m_root.insertLeft(0x0000);
        m_root.insertRight(0x0000);
        inOrder(m_root);
        var leftMost: ?*Node = m_root.lChild;

        for (0..16) |idx| {
            if (htable[idx].first == 0) {
                var current: ?*Node = leftMost;
                while (current != null) {
                    current.insertLeft(0x0000);
                    current.insertRight(0x0000);
                    current = current.getRightLevelNode();
                }
                leftMost = leftMost.lChild;
            } else {
                for (htable[idx].second) |huffVal| {
                    leftMost.value = huffVal;
                    leftMost.leaf = true;
                    leftMost = leftMost.getRightLevelNode();
                }
                leftMost.insertLeft(0x0000);
                leftMost.insertRight(0x0000);

                var current: ?*Node = leftMost.getRightLevelNode();
                leftMost = leftMost.lChild;

                while (current != null) {
                    current.insertLeft(0x0000);
                    current.insertRight(0x0000);

                    current = current.getRightLevelNode();
                }
            }
        }
        std.log.info("Finished building Huffman tree [OK]");
    }

    pub fn getTree(self: *HuffmanTree) *Node {
        return self.m_root;
    }

    pub fn contains(self: *HuffmanTree, code: u16) u16 {
        if (std.ascii.isWhitespace(@as(u8, code))) {
            std.log.warn("[ FATAL ] Invalid huffman code, possibly corrupt JFIF data stream!", .{});
            return 0;
        }

        var count: usize = 0;
        var current: ?*Node = self.m_root;
        const code_length = std.math.floor(std.math.log2(code)) + 1;

        while (true) {
            if ((code << (code_length + 1 - count) & 1) == 0) {
                current = current.lChild;
            } else {
                current = current.rChild;
            }
            if (current != null and current.lChild and current.code == code) {
                if (current.value == 0x0000) return 0;
                return current.value;
            }
            count += 1;
            if (current != null and count < code_length) {
                break;
            }
        }
        return 0;
    }
};

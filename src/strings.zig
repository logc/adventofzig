const std = @import("std");
const expect = std.testing.expect;
const mem = std.mem;

pub fn equals(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

test "string equality" {
    try expect(equals("aaa", "aaa") == true);
    try expect(equals("aaa", "bbb") == false);
}

pub fn countVowels(s: []const u8) u32 {
    var count: u32 = 0;
    for (s) |c| {
        if (c == 'a' or c == 'e' or c == 'i' or c == 'o' or c == 'u') {
            count += 1;
        }
    }
    return count;
}

pub fn countRepeated(s: []const u8) u32 {
    var count: u32 = 0;
    var prev: u8 = undefined;
    for (s, 0..) |chr, idx| {
        if (chr == prev and idx > 0) {
            count += 1;
        }
        prev = chr;
    }
    return count;
}

test "count repeated" {
    try expect(countRepeated("bb") == 1);
    try expect(countRepeated("abcdde") == 1);
    try expect(countRepeated("aabbccdd") == 4);
    try expect(countRepeated("aba") == 0);
}

pub fn countForbidden(s: []const u8) u32 {
    if (s.len == 0) return 0;
    var count: u32 = 0;
    var max = s.len - 1;
    for (s, 0..) |curr, i| {
        if (i == max) break;
        const next = s[i + 1];
        // ab, cd, pq, xy
        if ((curr == 'a' and next == 'b') or (curr == 'c' and next == 'd') or (curr == 'p' and next == 'q') or (curr == 'x' and next == 'y')) {
            count += 1;
        }
    }
    return count;
}

test "count forbidden" {
    try expect(countForbidden("ab") == 1);
    try expect(countForbidden("cd") == 1);
    try expect(countForbidden("pq") == 1);
    try expect(countForbidden("xy") == 1);
    try expect(countForbidden("abxy") == 2);
}

pub fn countRepeatedNoOverlap(alloc: mem.Allocator, s: []const u8) !u32 {
    if (s.len <= 3) return 0;
    const Pair = struct { first: u8, second: u8, idx: usize };
    var pairs = std.ArrayList(Pair).init(alloc);
    defer pairs.deinit();
    var max = s.len - 1;
    var count: u32 = 0;
    for (s, 0..) |c, i| {
        if (i == max) break;
        const newPair = Pair{ .first = c, .second = s[i + 1], .idx = i };
        for (pairs.items) |pair| {
            if (newPair.first == pair.first and newPair.second == pair.second and i > pair.idx + 1) {
                count += 1;
            }
        }
        try pairs.append(newPair);
    }
    return count;
}

test "count repeat no overlap" {
    const alloc = std.testing.allocator;
    try expect(try countRepeatedNoOverlap(alloc, "aaa") == 0);
    try expect(try countRepeatedNoOverlap(alloc, "baaa") == 0);
    try expect(try countRepeatedNoOverlap(alloc, "xyxy") == 1);
}

pub fn countRepeatWithOneBetween(s: []const u8) u32 {
    if (s.len < 3) return 0;
    var max = s.len - 2;
    var count: u32 = 0;
    for (s, 0..) |c, i| {
        if (i == max) break;
        if (c == s[i + 2]) {
            count += 1;
        }
    }
    return count;
}

test "count repeat with one between" {
    try expect(countRepeatWithOneBetween("xyx") == 1);
    try expect(countRepeatWithOneBetween("abcdefeghi") == 1);
    try expect(countRepeatWithOneBetween("aaa") == 1);
}

const std = @import("std");

pub fn equals(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

test "string equality" {
    try std.testing.expect(equals("aaa", "aaa") == true);
    try std.testing.expect(equals("aaa", "bbb") == false);
}

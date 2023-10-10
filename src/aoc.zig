const std = @import("std");
const expect = std.testing.expect;

const Solutions = struct { first: i32, second: i32 };

pub fn notQuiteLisp(directions: []const u8) Solutions {
    var floor: i32 = 0;
    var basement: i32 = 0;
    var found = false;
    for (directions, 0..) |d, index| {
        if (d == '(') floor += 1;
        if (d == ')') floor -= 1;
        if (floor == -1 and !found) {
            basement = @as(i32, @intCast(index)) + 1;
            found = true;
        }
    }
    return Solutions{ .first = floor, .second = basement };
}

test "not quite lisp" {
    const dirs1 = "(())";
    try expect(notQuiteLisp(dirs1).first == 0);

    const dirs2 = "()()";
    try expect(notQuiteLisp(dirs2).first == 0);

    const dirs3 = "(((";
    try expect(notQuiteLisp(dirs3).first == 3);

    const dirs4 = "(()(()(";
    try expect(notQuiteLisp(dirs4).first == 3);

    const dirs5 = "))(((((";
    try expect(notQuiteLisp(dirs5).first == 3);

    const dirs6 = "())";
    try expect(notQuiteLisp(dirs6).first == -1);

    const dirs7 = "))(";
    try expect(notQuiteLisp(dirs7).first == -1);

    const dirs8 = ")))";
    try expect(notQuiteLisp(dirs8).first == -3);

    const dirs9 = ")())())";
    try expect(notQuiteLisp(dirs9).first == -3);
}

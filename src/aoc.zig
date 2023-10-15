const std = @import("std");
const mem = std.mem;

const expect = std.testing.expect;

pub const Solutions = struct { first: i32, second: i32 };

pub fn perfectlySphericalHousesInAVacuum(alloc: mem.Allocator, input: []const u8) !Solutions {
    const positionsCount = try moveSanta(alloc, input);
    const doublePositionsCount = try moveSantaAndRobo(alloc, input);

    const uniques = @as(i32, @intCast(positionsCount));
    const doubleUniques = @as(i32, @intCast(doublePositionsCount));
    return Solutions{ .first = uniques, .second = doubleUniques };
}

fn moveSanta(alloc: mem.Allocator, input: []const u8) !u32 {
    const Position = struct { x: i32, y: i32 };
    var positions = std.AutoHashMap(Position, void).init(alloc);
    defer positions.deinit();
    var santa = Position{ .x = 0, .y = 0 };
    try positions.put(santa, {});
    for (input) |char| {
        if (char == '>') santa.x += 1;
        if (char == '<') santa.x -= 1;
        if (char == '^') santa.y += 1;
        if (char == 'v') santa.y -= 1;
        try positions.put(santa, {});
    }
    return positions.count();
}

fn moveSantaAndRobo(alloc: mem.Allocator, input: []const u8) !u32 {
    const Position = struct { x: i32, y: i32 };
    var doublePositions = std.AutoHashMap(Position, void).init(alloc);
    defer doublePositions.deinit();
    var newSanta = Position{ .x = 0, .y = 0 };
    var roboSanta = Position{ .x = 0, .y = 0 };
    try doublePositions.put(newSanta, {});
    try doublePositions.put(roboSanta, {});
    for (input, 0..) |char, idx| {
        if (idx % 2 == 0) {
            if (char == '>') newSanta.x += 1;
            if (char == '<') newSanta.x -= 1;
            if (char == '^') newSanta.y += 1;
            if (char == 'v') newSanta.y -= 1;
        }
        if (idx % 2 != 0) {
            if (char == '>') roboSanta.x += 1;
            if (char == '<') roboSanta.x -= 1;
            if (char == '^') roboSanta.y += 1;
            if (char == 'v') roboSanta.y -= 1;
        }
        try doublePositions.put(newSanta, {});
        try doublePositions.put(roboSanta, {});
    }
    return doublePositions.count();
}

test "Perfectly Spherical Houses In A Vacuum" {
    const alloc = std.testing.allocator;
    const input1 = ">";
    try expect((try perfectlySphericalHousesInAVacuum(alloc, input1)).first == 2);

    const input2 = "^>v<";
    try expect((try perfectlySphericalHousesInAVacuum(alloc, input2)).first == 4);

    const input3 = "^v^v^v^v^v";
    try expect((try perfectlySphericalHousesInAVacuum(alloc, input3)).first == 2);

    const input4 = "^v";
    try expect((try perfectlySphericalHousesInAVacuum(alloc, input4)).second == 3);

    const input5 = "^>v<";
    try expect((try perfectlySphericalHousesInAVacuum(alloc, input5)).second == 3);

    const input6 = "^v^v^v^v^v";
    try expect((try perfectlySphericalHousesInAVacuum(alloc, input6)).second == 11);
}

pub fn iWasToldThereWouldBeNoMath(input: []const u8) Solutions {
    const Dimensions = struct { l: i32, w: i32, h: i32 };
    var lines = std.mem.split(u8, input, "\n");
    var paper: i32 = 0;
    var ribbon: i32 = 0;
    while (lines.next()) |line| {
        var tokens = std.mem.split(u8, line, "x");
        var dims = Dimensions{ .l = 0, .w = 0, .h = 0 };
        var idx: u8 = 0;
        while (tokens.next()) |token| : (idx += 1) {
            const dim = std.fmt.parseInt(i32, token, 10) catch 0;
            if (idx == 0) dims.l = dim;
            if (idx == 1) dims.w = dim;
            if (idx == 2) dims.h = dim;
        }
        const min_side = min(dims.l * dims.w, dims.w * dims.h, dims.h * dims.l);
        paper += (2 * dims.l * dims.w + 2 * dims.w * dims.h + 2 * dims.h * dims.l);
        paper += min_side;
        ribbon += min_perimeter(dims.l, dims.w, dims.h);
        ribbon += dims.l * dims.w * dims.h;
    }
    return Solutions{ .first = paper, .second = ribbon };
}

fn min_perimeter(a: i32, b: i32, c: i32) i32 {
    var a_b = a * 2 + b * 2;
    var b_c = b * 2 + c * 2;
    var a_c = a * 2 + c * 2;
    return min(a_b, b_c, a_c);
}

fn min(a: i32, b: i32, c: i32) i32 {
    var min_val = a;
    if (b < min_val) {
        min_val = b;
    }
    if (c < min_val) {
        min_val = c;
    }
    return min_val;
}

test "min" {
    try expect(min(1, 2, 3) == 1);
    try expect(min(1, 1, 1) == 1);
    try expect(min(3, 2, 1) == 1);
    try expect(min(3, 1, 2) == 1);
}

test "I Was Told There Would Be No Math" {
    const dims1 = "2x3x4\n";
    try expect(iWasToldThereWouldBeNoMath(dims1).first == (2 * 6 + 2 * 12 + 2 * 8) + 6);

    const dims2 = "1x1x10\n";
    try expect(iWasToldThereWouldBeNoMath(dims2).first == (2 * 1 + 2 * 10 + 2 * 10) + 1);

    const dims3 = "2x3x4\n1x1x10";
    try expect(iWasToldThereWouldBeNoMath(dims3).first == (58 + 43));
}

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

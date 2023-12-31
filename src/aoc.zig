const std = @import("std");
const str = @import("strings.zig");
const mem = std.mem;
const Md5 = std.crypto.hash.Md5;

const expect = std.testing.expect;

pub const Solutions = struct { first: i32, second: i32 };

const InstructionType = enum { turnOn, turnOff, toggle };
const GridPosition = struct { x: u32, y: u32 };
const Instruction = struct { itype: InstructionType, topLeft: GridPosition, bottomRight: GridPosition };

pub fn Grid(comptime m: usize, comptime n: usize) type {
    return struct {
        const Self = @This();

        pub const rows = m;
        pub const cols = n;

        data: [rows * cols]bool,

        pub fn init() Self {
            return Self{ .data = [_]bool{false} ** (rows * cols) };
        }

        pub fn get(self: Self, row: usize, col: usize) bool {
            return self.data[row * cols + col];
        }

        pub fn set(self: Self, row: usize, col: usize, val: bool) void {
            self.data[row * cols + col] = val;
        }
    };
}

test "Grid" {}

pub fn probablyAFireHazard(input: []const u8) Solutions {
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        const instruction = parseInstruction(line);
        performInstruction(instruction);
    }
}

fn performInstruction(instruction: Instruction, grid: Grid) void {
    _ = grid;
    _ = instruction;
}

test "perform instructions" {
    var instruction = Instruction{ .itype = InstructionType.toggle, .topLeft = GridPosition{ .x = 0, .y = 0 }, .bottomRight = GridPosition{ .x = 3, .y = 3 } };
    const actual = performInstruction(instruction, grid);
    //try expect(std.meta.eql(actual, expected));
    try expect(actual == expected);
}

fn parseInstruction(line: []const u8) !Instruction {
    var idx: usize = 0;
    var instructionType = InstructionType.toggle;
    if (str.equals(line[0..6], "toggle")) {
        idx = 6;
        instructionType = InstructionType.toggle;
    }
    if (str.equals(line[0..7], "turn on")) {
        idx = 7;
        instructionType = InstructionType.turnOn;
    }
    if (str.equals(line[0..8], "turn off")) {
        idx = 8;
        instructionType = InstructionType.turnOff;
    }
    const rest = line[idx + 1 .. line.len];
    var tokens = std.mem.split(u8, rest, " ");
    const topLeftToken = tokens.next().?;
    const topLeftPos = try parsePosition(topLeftToken);
    _ = tokens.next().?;
    const bottomRightToken = tokens.next().?;
    const bottomRightPos = try parsePosition(bottomRightToken);
    return Instruction{ .itype = instructionType, .topLeft = topLeftPos, .bottomRight = bottomRightPos };
}

fn parsePosition(token: []const u8) !GridPosition {
    var xYTokens = std.mem.split(u8, token, ",");
    const x = try std.fmt.parseInt(u32, xYTokens.next().?, 10);
    const y = try std.fmt.parseInt(u32, xYTokens.next().?, 10);
    return GridPosition{ .x = x, .y = y };
}

test "parse instruction" {
    const example1 = "toggle 461,550 through 564,900";
    const expected1 = Instruction{ .itype = InstructionType.toggle, .topLeft = GridPosition{ .x = 461, .y = 550 }, .bottomRight = GridPosition{ .x = 564, .y = 900 } };
    const actual1 = parseInstruction(example1);
    try expect(std.meta.eql(actual1, expected1));

    const example2 = "toggle 50,472 through 452,788";
    const expected2 = Instruction{ .itype = InstructionType.toggle, .topLeft = GridPosition{ .x = 50, .y = 472 }, .bottomRight = GridPosition{ .x = 452, .y = 788 } };
    const actual2 = parseInstruction(example2);
    try expect(std.meta.eql(actual2, expected2));

    const example3 = "turn on 0,0 through 999,999";
    const expected3 = Instruction{ .itype = InstructionType.turnOn, .topLeft = GridPosition{ .x = 0, .y = 0 }, .bottomRight = GridPosition{ .x = 999, .y = 999 } };
    const actual3 = parseInstruction(example3);
    try expect(std.meta.eql(actual3, expected3));

    const example4 = "turn off 499,499 through 500,500";
    const expected4 = Instruction{ .itype = InstructionType.turnOff, .topLeft = GridPosition{ .x = 499, .y = 499 }, .bottomRight = GridPosition{ .x = 500, .y = 500 } };
    const actual4 = parseInstruction(example4);
    try expect(std.meta.eql(actual4, expected4));
}

pub fn doesntHeHaveInternElvesForThis(alloc: mem.Allocator, input: []const u8) !Solutions {
    var lines = std.mem.split(u8, input, "\n");
    var niceLineCount: i32 = 0;
    var newNiceLinesCount: i32 = 0;
    while (lines.next()) |line| {
        if (isNice(line)) niceLineCount += 1;
        if (try isNewNice(alloc, line)) newNiceLinesCount += 1;
    }
    return Solutions{ .first = niceLineCount, .second = newNiceLinesCount };
}

fn isNice(s: []const u8) bool {
    const vowelsCount = str.countVowels(s);
    const repeatsCount = str.countRepeated(s);
    const forbiddenCount = str.countForbidden(s);
    return vowelsCount >= 3 and repeatsCount >= 1 and forbiddenCount == 0;
}

fn isNewNice(alloc: mem.Allocator, s: []const u8) !bool {
    const repeatNoOverlapCount = try str.countRepeatedNoOverlap(alloc, s);
    const repeatWithOneBetweeCount = str.countRepeatWithOneBetween(s);
    return repeatNoOverlapCount > 0 and repeatWithOneBetweeCount > 0;
}

test "Doesn't He Have Intern-Elves For This?" {
    try expect(isNice("ugknbfddgicrmopn") == true);
    try expect(isNice("aaa") == true);
    try expect(isNice("jchzalrnumimnmhp") == false);
    try expect(isNice("haegwjzuvuyypxyu") == false);
    try expect(isNice("dvszwmarrgswjxmb") == false);

    const alloc = std.testing.allocator;
    try expect(try isNewNice(alloc, "qjhvhtzxzqqjkmpb") == true);
    try expect(try isNewNice(alloc, "xxyxx") == true);
    try expect(try isNewNice(alloc, "uurcxstgmygtbstg") == false);
    try expect(try isNewNice(alloc, "ieodomkazucvgmuy") == false);
}

pub fn theIdealStockingStuffer(alloc: mem.Allocator, input: []const u8) !Solutions {
    var num: i32 = 0;
    var fiveNotFound = true;
    var sixNotFound = true;
    var lowestFiveZeros: i32 = 0;
    var lowestSixZeros: i32 = 0;
    const seed = mem.trimRight(u8, input, "\n");
    while (fiveNotFound or sixNotFound) : (num += 1) {
        var s = std.fmt.allocPrint(alloc, "{d}", .{num}) catch @panic("Unhandled");
        defer alloc.free(s);
        var h = Md5.init(.{});
        var buf: [Md5.digest_length]u8 = undefined;
        h.update(seed);
        h.update(s);
        h.final(&buf);
        var hash_hex = std.fmt.allocPrint(alloc, "{s}", .{std.fmt.fmtSliceHexUpper(&buf)}) catch @panic("Unhandled");
        defer alloc.free(hash_hex);
        if (mem.eql(u8, hash_hex[0..5], "00000") and fiveNotFound) {
            fiveNotFound = false;
            lowestFiveZeros = num;
        }
        if (mem.eql(u8, hash_hex[0..6], "000000")) {
            sixNotFound = false;
            lowestSixZeros = num;
        }
    }
    return Solutions{ .first = lowestFiveZeros, .second = lowestSixZeros };
}

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

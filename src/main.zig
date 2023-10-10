const clap = @import("clap");
const std = @import("std");
const aoc = @import("aoc.zig");

const debug = std.debug;
const io = std.io;
const mem = std.mem;

const CliArgs = struct { year: []const u8, day: []const u8 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const cliArgs = try readCli(alloc);
    var puzzleInput = try readPuzzleInput(alloc, cliArgs.year, cliArgs.day);
    var solutions = aoc.notQuiteLisp(puzzleInput);
    std.debug.print("Puzzle 1: {d}\nPuzzle 2: {d}\n", .{ solutions.first, solutions.second });
}

fn readCli(alloc: mem.Allocator) !CliArgs {
    _ = alloc;
    const params = comptime clap.parseParamsComptime(
        \\-y, --year <str>   Year of advent problem to solve.
        \\-d, --day <str>    Day within year to solve.
    );
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{ .diagnostic = &diag }) catch |err| {
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();
    var year: []const u8 = "2015";
    var day: []const u8 = "01";
    if (res.args.year) |year_set| {
        year = year_set;
    }
    if (res.args.day) |day_set| {
        day = day_set;
    }
    return CliArgs{ .year = year, .day = day };
}

fn readPuzzleInput(alloc: mem.Allocator, year: ?[]const u8, day: ?[]const u8) ![]const u8 {
    const filename = try std.fmt.allocPrint(alloc, "var/data/{?s}/{?s}/input.txt", .{ year, day });
    defer alloc.free(filename);
    std.debug.print("Opening: {s}\n", .{filename});
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var buf: [10000]u8 = undefined;
    const read = try file.read(&buf);
    _ = read;
    return &buf;
}

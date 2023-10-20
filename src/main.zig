const clap = @import("clap");
const std = @import("std");
const aoc = @import("aoc.zig");
const str = @import("strings.zig");

const debug = std.debug;
const io = std.io;
const mem = std.mem;

const CliArgs = struct { year: []const u8, day: []const u8 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    const cliArgs = try readCli();
    var puzzleInput = readPuzzleInput(alloc, cliArgs.year, cliArgs.day) catch "";
    defer alloc.free(puzzleInput);
    var solutions = aoc.Solutions{ .first = 0, .second = 0 };
    if (str.equals(cliArgs.year, "2015")) {
        if (str.equals(cliArgs.day, "01")) {
            solutions = aoc.notQuiteLisp(puzzleInput);
        }
        if (str.equals(cliArgs.day, "02")) {
            solutions = aoc.iWasToldThereWouldBeNoMath(puzzleInput);
        }
        if (str.equals(cliArgs.day, "03")) {
            solutions = try aoc.perfectlySphericalHousesInAVacuum(alloc, puzzleInput);
        }
        if (str.equals(cliArgs.day, "04")) {
            solutions = try aoc.theIdealStockingStuffer(alloc, puzzleInput);
        }
        if (str.equals(cliArgs.day, "05")) {
            solutions = try aoc.doesntHeHaveInternElvesForThis(alloc, puzzleInput);
        }
    }
    std.debug.print("Puzzle 1: {d}\nPuzzle 2: {d}\n", .{ solutions.first, solutions.second });
}

fn readCli() !CliArgs {
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
    const nameTemp = "var/data/{?s}/{?s}/input.txt";
    const filename = try std.fmt.allocPrint(alloc, nameTemp, .{ year, day });
    defer alloc.free(filename);
    std.debug.print("Opening file: {s}\n", .{filename});
    const file = std.fs.cwd().openFile(filename, .{}) catch |err| {
        if (err == error.FileNotFound) {
            std.debug.print("{s} not found\n", .{filename});
            return err;
        }
        return err;
    };
    defer file.close();
    return file.readToEndAlloc(alloc, 1024 * 1024);
}

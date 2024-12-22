const std = @import("std");

pub fn echo(_: std.mem.Allocator, args: []u8, _: u8) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}\n", .{args});
}

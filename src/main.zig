const std = @import("std");
const pkg = @import("check.zig");
const posix = std.posix;

pub fn main() !void {
    // Uncomment this block to pass the first stage
    const allocator = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();
    try stdout.print("$ ", .{});

    const stdin = std.io.getStdIn().reader();
    var buffer: [1024]u8 = undefined;
    const user_input = try stdin.readUntilDelimiter(&buffer, '\n');

    // Dynamically allocate a slice of strings
    var paths = try allocator.alloc([]const u8, 3);
    defer allocator.free(paths);

    // Directly assign the paths
    paths[0] = "/bin";
    paths[1] = "/usr/bin";
    paths[2] = "/usr/local/bin";

    const val = try pkg.check(allocator, user_input, paths);
    if (!val) {
        try stdout.print("{s}: command not found\n", .{user_input});
        posix.exit(1);
    }

    posix.exit(0);
}

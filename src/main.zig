const std = @import("std");
const gateway = @import("gateway.zig");
const posix = std.posix;

pub fn main() !void {
    // Uncomment this block to pass the first stage
    const allocator = std.heap.page_allocator;
    // Dynamically allocate a slice of strings

    while (true) {
        const stdout = std.io.getStdOut().writer();
        try stdout.print("$ ", .{});

        const stdin = std.io.getStdIn().reader();
        var buffer: [1024]u8 = undefined;
        const user_input = try stdin.readUntilDelimiter(&buffer, '\n');
        gateway.gateway(allocator, user_input, 0) catch |err| {
            std.log.err("Failed to run gateway: {s}", .{@errorName(err)});
        };
    }

    posix.exit(0);
}

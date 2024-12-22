const std = @import("std");
const fs = std.fs;
const posix = std.posix;

pub fn check(_: std.mem.Allocator, bin: []const u8, path: [][]const u8) !bool {
    var buffer: [1024]u8 = undefined; // Temporary buffer for constructing the path
    for (path) |dir| {
        const bin_path = try std.fmt.bufPrint(&buffer, "{s}/{s}", .{ dir, bin });

        // const as_slice = std.mem.Allocator.dupeZ(allocator, u8, bin_path) catch unreachable;
        // defer allocator.free(as_slice);

        // if (std.os.linux.access(as_slice, std.posix.X_OK) == 0) {
        //     return true;
        // }

        posix.access(bin_path, posix.X_OK) catch {
            // std.log.err("Failed to access {s}: {s}", .{ bin_path, @errorName(err) });
            continue;
        };

        return true;
    }
    return false;
}

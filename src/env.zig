const std = @import("std");
const posix = std.posix;

pub fn get_env(allocator: std.mem.Allocator, k: []const u8) ![]const u8 {
    const res = try std.process.getEnvVarOwned(allocator, k);

    return res;
}

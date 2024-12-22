const std = @import("std");
const posix = std.os.posix;

pub fn check(bin: []const u8, path: [][]const u8) !bool {
    for (path) |string| {
        const bin_path = string ++ "/" ++ bin;
        if (posix.access(bin_path, posix.X_OK)) {
            return true;
        }
    }

    return false;
}

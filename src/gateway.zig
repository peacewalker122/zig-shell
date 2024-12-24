const std = @import("std");
const types = @import("types.zig");
const pkg = @import("check.zig");
const env = @import("env.zig");
const stdout = std.io.getStdOut().writer();
const posix = std.posix;

const err = error{
    ArgumentNotProvidedError,
};

pub fn gateway(allocator: std.mem.Allocator, args: []u8, _: u8) !void {
    var it = std.mem.splitScalar(u8, args, ' ');

    var arg = std.ArrayList([]const u8).init(allocator);
    defer arg.deinit();

    while (it.next()) |v| {
        try arg.append(v);
    }

    const PATH = try env.get_env(allocator, "PATH");
    defer allocator.free(PATH);

    var it2 = std.mem.splitScalar(u8, PATH, ':');
    var paths_arr = std.ArrayList([]const u8).init(allocator);

    while (it2.next()) |v| {
        try paths_arr.append(v);
    }

    const input = arg.items;
    const paths = paths_arr.items;

    const builtin = types.BUILTIN.assign_enum(input[0]);

    if (!types.BUILTIN.is_builtin(builtin)) {
        // HANDLE non builtin here
        const val = try pkg.check(allocator, input[0], paths);
        if (!val.is_executable) {
            try stdout.print("{s}: command not found\n", .{args});
            return;
        }

        const pid = try posix.fork();

        if (pid == 0) {
            var arguments = std.ArrayList([]const u8).init(allocator);

            for (input, 0..) |value, i| {
                _ = i;

                try arguments.append(value);
            }

            std.process.execv(allocator, arguments.items) catch unreachable;
        }

        _ = posix.waitpid(pid, 0);
    }

    // NOTE: This is where we would handle the builtin commands
    if (builtin == types.BUILTIN.exit) {
        if (arg.items.len < 2) {
            // assume exit 0
            posix.exit(0);
        }

        const exit_code = try std.fmt.parseInt(u8, input[1], 10);
        posix.exit(exit_code);
    }

    if (builtin == types.BUILTIN.echo) {
        if (arg.items.len < 2) {
            return err.ArgumentNotProvidedError;
        }

        for (arg.items, 0..) |value, i| {
            if (i == 0) {
                continue; // skip 'echo'
            }

            try stdout.print("{s} ", .{value});
        }

        try stdout.print("\n", .{});
    }

    if (builtin == types.BUILTIN.TYPE) {
        if (arg.items.len < 2) {
            return err.ArgumentNotProvidedError;
        }

        const is_builtin = types.BUILTIN.is_builtin(types.BUILTIN.assign_enum(input[1]));

        if (is_builtin) {
            try stdout.print("{s} is a shell builtin\n", .{input[1]});
        } else {
            const val = try pkg.check(allocator, input[1], paths);
            if (!val.is_executable) {
                try stdout.print("{s}: not found\n", .{input[1]});
                return;
            }

            stdout.print("{s} is {s}\n", .{ input[1], val.path }) catch unreachable;
        }
    }

    if (builtin == types.BUILTIN.pwd) {
        var buffer = try allocator.alloc(u8, 1024);

        while (true) {
            const cwd = posix.getcwd(buffer) catch |e| {
                if (e == posix.GetCwdError.NameTooLong) {
                    buffer = try allocator.realloc(buffer, buffer.len * 2);
                    continue;
                }

                std.log.err("Error: {s}", .{@errorName(e)});
                return;
            };

            // Successfully retrieved cwd
            try stdout.print("{s}\n", .{cwd});
            break;
        }
    }

    if (builtin == types.BUILTIN.cd) {
        if (arg.items.len < 2) {
            return err.ArgumentNotProvidedError;
        }

        const path = arg.items[1];

        var dir = std.fs.cwd().openDir(path, .{}) catch {
            try stdout.print("cd: {s}: No such file or directory\n", .{path});
            return;
        };
        defer dir.close();

        try dir.setAsCwd();
    }
}

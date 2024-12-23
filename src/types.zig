const std = @import("std");

pub const BUILTIN = enum {
    exit,
    cd,
    echo,
    TYPE,
    invalid,

    pub fn assign_enum(val: []const u8) BUILTIN {
        if (std.mem.eql(u8, val, "exit")) {
            return BUILTIN.exit;
        }

        if (std.mem.eql(u8, val, "cd")) {
            return BUILTIN.cd;
        }

        if (std.mem.eql(u8, val, "echo")) {
            return BUILTIN.echo;
        }

        if (std.mem.eql(u8, val, "type")) {
            return BUILTIN.TYPE;
        }

        return BUILTIN.invalid;
    }

    pub fn is_builtin(val: BUILTIN) bool {
        return switch (val) {
            .exit => true,
            .cd => true,
            .echo => true,
            .TYPE => true,
            .invalid => false,
        };
    }
};

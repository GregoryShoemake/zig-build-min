const std = @import("std");

pub fn leaf(path: []const u8, trimExtension: bool) []const u8 {
    var end: usize = path.len - 1;
    var start: usize = end;
    while (start >= 0) {
        if (path[start] == '\\' or path[start] == '/') {
            start += 1;
            break;
        }
        start -= 1;
    }
    if (trimExtension) {
        while (end >= start) {
            if (path[end] == '.') {
                end -= 1;
                break;
            }
            end -= 1;
        }
        if (end == start) {
            end = path.len - 1;
        }
    }
    return path[start..(end + 1)];
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const paths = &[_][]const u8 {
        "src/root.zig",
    };

    const exe = b.addExecutable(.{
        .name = "zig",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize
    });
 

    for (paths) |path| {

        if(std.mem.endsWith(u8, path, ".zig")) {
            const lib = b.addStaticLibrary(.{
                .name = leaf(path, true),
                .root_source_file = b.path(path),
                .target = target,
                .optimize = optimize
            });
            exe.linkLibrary(lib);
            b.installArtifact(lib);
        } else {
            const module = b.dependency(path, .{
                .target = target,
                .optimize = optimize,
            });
            exe.root_module.addImport(path, module.module(path));
        }
    }

    b.installArtifact(exe);
}

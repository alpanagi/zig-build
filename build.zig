const std = @import("std");

const CLibrary = struct {
    module: *std.Build.Module,
    system_library: ?[]const u8 = null,
    sources: ?[]const []const u8 = null,
};

fn addSystemCLibrary(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    translation_header: []const u8,
    library: []const u8,
) CLibrary {
    const translateC = b.addTranslateC(.{
        .root_source_file = b.path(translation_header),
        .target = target,
        .optimize = optimize,
    });
    translateC.link_libc = true;
    translateC.linkSystemLibrary(library, .{});
    return .{ .module = translateC.createModule(), .system_library = library };
}

fn addLocalCLibrary(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    translation_header: []const u8,
    sources: []const []const u8,
) CLibrary {
    const translateC = b.addTranslateC(.{
        .root_source_file = b.path(translation_header),
        .target = target,
        .optimize = optimize,
    });
    translateC.link_libc = true;
    return .{ .module = translateC.createModule(), .sources = sources };
}

fn linkCLibraries(
    build_step: *std.Build.Module,
    libraries: []const CLibrary,
    compile_sources: bool,
) void {
    build_step.link_libc = true;
    for (libraries) |library| {
        if (library.system_library) |name| build_step.linkSystemLibrary(name, .{});
        if (compile_sources) {
            if (library.sources) |sources| {
                build_step.addCSourceFiles(.{ .files = sources });
            }
        }
    }
}

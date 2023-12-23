const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const bench = b.addExecutable(.{
        .name = "bench",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("bench.zig"),
    });
    add_zig_files(b, bench, &.{
        "tigerbeetle.zig",
        "constants.zig",
        "storage.zig",
        "io.zig",
        "message_pool.zig",
        "message_bus.zig",
        "state_machine.zig",
        "ring_buffer.zig",
        "vsr.zig",
        "stdx.zig",
    });

    const run_cmd = b.addRunArtifact(bench);
    run_cmd.step.dependOn(b.getInstallStep());

    const bench_build = b.step("run", "Run the Zig client bench");
    bench_build.dependOn(&run_cmd.step);
}

fn add_zig_files(b: *std.Build, exe: *std.Build.Step.Compile, comptime files: []const []const u8) void {
    const options = b.addOptions();
    const ConfigBase = enum {
        production,
        development,
        test_min,
        default,
    };

    options.addOption(
        ConfigBase,
        "config_base",
        .default,
    );

    options.addOption(
        std.log.Level,
        "config_log_level",
        .info,
    );

    const TracerBackend = enum {
        none,
        perfetto,
        tracy,
    };
    options.addOption(
        TracerBackend,
        "tracer_backend",
        .none,
    );

    options.addOption(
        ?[40]u8,
        "git_commit",
        null,
    );

    options.addOption(
        ?[]const u8,
        "release",
        null,
    );

    options.addOption(
        ?[]const u8,
        "release_client_min",
        null,
    );

    const aof_record_enable = b.option(bool, "config-aof-record", "Enable AOF Recording.") orelse false;
    const aof_recovery_enable = b.option(bool, "config-aof-recovery", "Enable AOF Recovery mode.") orelse false;
    options.addOption(bool, "config_aof_record", aof_record_enable);
    options.addOption(bool, "config_aof_recovery", aof_recovery_enable);

    const HashLogMode = enum {
        none,
        create,
        check,
    };
    options.addOption(HashLogMode, "hash_log_mode", .none);
    const vsr_options = options.createModule();

    inline for (files) |file| {
        const pkg = b.createModule(.{
            .root_source_file = b.path("../tigerbeetle/src/" ++ file),
            .imports = &.{
                .{
                    .name = "vsr_options",
                    .module = vsr_options,
                },
            },
        });
        exe.root_module.addImport(file, pkg);
    }
}

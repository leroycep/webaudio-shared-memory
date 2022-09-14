const std = @import("std");
const wasmserve = @import("libs/wasmserve/wasmserve.zig");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = std.Target.Cpu.Arch.wasm32,
            .os_tag = .freestanding,
            .cpu_features_add = std.Target.wasm.featureSet(&.{
                // Needed for shared memory
                .atomics,
                .bulk_memory,
            }),
        },
    });

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("webaudio-shared-memory", "src/main.zig");
    exe.addPackagePath("sysjs", "libs/sysjs/src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();
    exe.import_memory = true;
    exe.shared_memory = true;

    const install_sysjs = b.addInstallFile(.{ .path = "libs/sysjs/src/mach-sysjs.js" }, "mach-sysjs.js");
    b.getInstallStep().dependOn(&install_sysjs.step);

    const install_index = b.addInstallFile(.{ .path = "src/index.html" }, "index.html");
    b.getInstallStep().dependOn(&install_index.step);

    const serve_step = wasmserve.serve(exe, ".", .{
        .watch_paths = &.{
            "src/main.zig",
            "src/index.html",
            "libs/sysjs/src/mach-sysjs.js",
        },
        .serve_path = "zig-out/",
    }) catch unreachable;
    const run_step = b.step("run", "Run development web server");
    run_step.dependOn(&serve_step.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

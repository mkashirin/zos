const std = @import("std");

const Target = std.Target;
const CrossTarget = std.zig.CrossTarget;

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Here we set the target to be an x86 bare metal chip without any OS.
    // This allows for our program to be run as a freestanding binary.
    const target: CrossTarget = .{
        .cpu_arch = .x86,
        .os_tag = .freestanding,
    };

    // Standard optimization options allow the person running `zig build` to
    // select between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here
    // we do not set a preferred release mode, allowing the user to decide
    // how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const kernel = b.addExecutable(.{
        .name = "zos",
        .root_source_file = b.path("src/kernel.zig"),
        .target = b.resolveTargetQuery(target),
        .optimize = optimize,
    });
    // Since we have no OS, we need to provide a path to the linker script, so
    // that our files are linked properly.
    kernel.setLinkerScriptPath(b.path("src/linker.ld"));
    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(kernel);

    // When the kernel is compiled, we can run QEMU directly from the build
    // script! Path to the kernel is required to be passed to the `-kernel`
    // flag ro run it.
    const run_qemu = b.addSystemCommand(&[_][]const u8{
        "qemu-system-x86_64",
        "-kernel",
        "./zig-out/bin/zos",
    });
    // Then we make the run step depend on the kernel compilation step for
    // obvious reasons.
    run_qemu.step.dependOn(&kernel.step);
    const run_kernel = b.step("run", "Run the kernel");
    run_kernel.dependOn(&run_qemu.step);
}

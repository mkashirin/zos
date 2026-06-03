const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Here we set the target to be an x86 bare metal chip without any OS.
    // This allows for our program to be run as a freestanding binary.
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86,
        .os_tag = .freestanding,
        .abi = .none,
    });

    const kernel_module = b.createModule(.{
        .root_source_file = b.path("src/kernel.zig"),
        .target = target,
        .optimize = .ReleaseSmall,
        .code_model = .kernel,
        .error_tracing = false,
        .single_threaded = true,
        .strip = true,
    });
    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_module = kernel_module,
    });
    kernel.out_filename = "kernel.elf";
    // Since we have no OS, we need to provide a path to the linker script, so
    // that our files are linked properly.
    kernel.setLinkerScript(b.path("src/linker.ld"));
    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(kernel);

    // When the kernel is compiled, we can run QEMU directly from the build
    // script! Path to the kernel is required to be passed to the `-kernel`
    // flag ro run it.
    const run_qemu = b.addSystemCommand(&.{
        "qemu-system-x86_64",
        "-kernel",
        "./zig-out/bin/kernel.elf",
    });
    // Then we make the run step depend on the kernel compilation step for
    // obvious reasons.
    run_qemu.step.dependOn(&kernel.step);
    const run_kernel = b.step("run", "Run the kernel");
    run_kernel.dependOn(&run_qemu.step);
}

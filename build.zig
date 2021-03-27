const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("hello", "src/main.zig");
    // const exe = b.addExecutable("hello", null);
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();
    exe.linkLibC();

    // exe.linkSystemLibrary("notcurses-core");
    // exe.linkSystemLibrary("qrcodegen");
    exe.addObjectFile("/home/me/dl/git/notcurses/build/libnotcurses-core.a");

    exe.linkSystemLibrary("ncurses");
    exe.linkSystemLibrary("readline");
    exe.linkSystemLibrary("unistring");

    // exe.addCSourceFile("src/hello.c", &[_][]const u8{});

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

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

    const notcurses_source_path = "deps/notcurses";

    const notcurses = b.addStaticLibrary("notcurses", null);
    notcurses.setTarget(target);
    notcurses.setBuildMode(mode);
    notcurses.linkLibC();

    notcurses.linkSystemLibrary("ncurses");
    notcurses.linkSystemLibrary("readline");
    notcurses.linkSystemLibrary("unistring");

    notcurses.addIncludeDir(notcurses_source_path ++ "/include");
    notcurses.addIncludeDir(notcurses_source_path ++ "/build/include");
    notcurses.addIncludeDir(notcurses_source_path ++ "/src");
    notcurses.addCSourceFiles(&[_][]const u8{
        notcurses_source_path ++ "/src/lib/blit.c",
        notcurses_source_path ++ "/src/lib/debug.c",
        notcurses_source_path ++ "/src/lib/direct.c",
        notcurses_source_path ++ "/src/lib/fade.c",
        notcurses_source_path ++ "/src/lib/fd.c",
        notcurses_source_path ++ "/src/lib/fill.c",
        notcurses_source_path ++ "/src/lib/input.c",
        notcurses_source_path ++ "/src/lib/kitty.c",
        notcurses_source_path ++ "/src/lib/layout.c",
        notcurses_source_path ++ "/src/lib/linux.c",
        notcurses_source_path ++ "/src/lib/menu.c",
        notcurses_source_path ++ "/src/lib/metric.c",
        notcurses_source_path ++ "/src/lib/notcurses.c",
        notcurses_source_path ++ "/src/lib/progbar.c",
        notcurses_source_path ++ "/src/lib/reader.c",
        notcurses_source_path ++ "/src/lib/reel.c",
        notcurses_source_path ++ "/src/lib/render.c",
        notcurses_source_path ++ "/src/lib/selector.c",
        notcurses_source_path ++ "/src/lib/signal.c",
        notcurses_source_path ++ "/src/lib/sixel.c",
        notcurses_source_path ++ "/src/lib/sprite.c",
        notcurses_source_path ++ "/src/lib/stats.c",
        notcurses_source_path ++ "/src/lib/tabbed.c",
        notcurses_source_path ++ "/src/lib/terminfo.c",
        notcurses_source_path ++ "/src/lib/tree.c",
        notcurses_source_path ++ "/src/lib/visual.c",
        notcurses_source_path ++ "/src/compat/compat.c",
    }, &[_][]const u8{
        "-DUSE_MULTIMEDIA=none",
        "-DUSE_QRCODEGEN=OFF",
        "-DPOLLRDHUP=0x2000",
    });

    const exe = b.addExecutable("demo", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();
    exe.linkLibC();

    // exe.linkSystemLibrary("notcurses-core");
    // exe.addObjectFile(notcurses_source_path ++ "/build/libnotcurses-core.a");

    exe.addIncludeDir(notcurses_source_path ++ "/include");
    exe.linkLibrary(notcurses);

    exe.linkSystemLibrary("ncurses");
    exe.linkSystemLibrary("readline");
    exe.linkSystemLibrary("unistring");
    // exe.linkSystemLibrary("qrcodegen");

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

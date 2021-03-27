const c = @import("c.zig");
const default_notcurses_options = c.notcurses_options{
    .loglevel = c.ncloglevel_e.NCLOGLEVEL_SILENT,
    .termtype = null,
    .margin_r = 0,
    .margin_b = 0,
    .flags = 0,
    .renderfp = null,
    .margin_t = 0,
    .margin_l = 0,
};
pub fn main() void {
    var opts: c.notcurses_options = default_notcurses_options;
    opts.flags = c.NCOPTION_SUPPRESS_BANNERS;
    var nc: *c.notcurses = (c.notcurses_core_init(&opts, null) orelse @panic("notcurses_core_init() failed"));
    var dimy: c_int = undefined;
    var dimx: c_int = undefined;
    var n: *c.ncplane = (c.notcurses_stddim_yx(nc, &dimy, &dimx) orelse @panic("notcurses_stddim_yx() failed"));
    var ch: u8 = 'A';
    _ = c.ncplane_set_scrolling(n, true);
    while (true) {
        var req = c.timespec{
            .tv_sec = 0,
            .tv_nsec = 1000000,
        };
        _ = c.nanosleep(&req, null);
        if (c.ncplane_putchar(n, ch) != 1) break;
        ch += 1;
        if (ch == '{') ch = 'A';
        if (c.notcurses_render(nc) != 0) break;
    }
    _ = c.notcurses_stop(nc);
}

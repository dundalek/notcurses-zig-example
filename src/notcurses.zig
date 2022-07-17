const c = @cImport({
    @cInclude("notcurses/notcurses.h");
});
pub usingnamespace c;
pub const default_notcurses_options = c.notcurses_options{
    .termtype = null,
    .loglevel = c.NCLOGLEVEL_SILENT,
    .margin_t = 0,
    .margin_r = 0,
    .margin_b = 0,
    .margin_l = 0,
    .flags = 0,
};
pub const default_ncplane_options = c.ncplane_options{
    .y = 0,
    .userptr = null,
    .name = null,
    .rows = 0,
    .cols = 0,
    .margin_r = 0,
    .margin_b = 0,
    .x = 0,
    .flags = 0,
    .resizecb = null,
};
const default_ncselector_options = c.ncselector_options{
    .footchannels = 0,
    .boxchannels = 0,
    .defidx = 0,
    .opchannels = 0,
    .secondary = null,
    .footer = null,
    .title = null,
    .items = null,
    .flags = 0,
    .titlechannels = 0,
    .maxdisplay = 0,
    .descchannels = 0,
};
pub const Error = error{
    NotcursesError,
};
pub fn err(code: c_int) !void {
    if (code < 0) return Error.NotcursesError;
}

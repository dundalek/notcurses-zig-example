pub usingnamespace @cImport({
    @cInclude("notcurses/notcurses.h");
});
pub const default_notcurses_options = notcurses_options{
    .loglevel = ncloglevel_e.NCLOGLEVEL_SILENT,
    .termtype = null,
    .margin_r = 0,
    .margin_b = 0,
    .flags = 0,
    .renderfp = null,
    .margin_t = 0,
    .margin_l = 0,
};
pub const default_ncplane_options = ncplane_options{
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
const default_ncselector_options = ncselector_options{
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
var cnt: u64 = 0;
pub fn err(code: c_int) !void {
    if (code < 0) return error.NotcursesError;
}

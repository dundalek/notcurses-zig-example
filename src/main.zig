const std = @import("std");
const nc = @import("notcurses.zig");
const time = @import("time.zig");
const BOX_NUM: usize = 10;
const c_red: u32 = 14101551;
const c_yel: u32 = 16764969;
const c_blu: u32 = 3950975;
const c_whi: u32 = 16711422;
const box_colors = [BOX_NUM]u32{ c_red, c_whi, c_yel, c_whi, c_blu, c_whi, c_blu, c_yel, c_red, c_whi };
fn linear_transition(start: anytype, end: anytype, duration: u64, diff: u64) @TypeOf(start) {
    return (start + @intCast(@TypeOf(start), @divTrunc((end - start) * @intCast(i64, diff), @intCast(i64, duration))));
}

fn transition_rgb(start: u32, end: u32, duration: u64, diff: u64) u32 {
    var rgb: u32 = 0;
    var r = linear_transition(@intCast(c_int, nc.channel_r(start)), @intCast(c_int, nc.channel_r(end)), duration, diff);
    var g = linear_transition(@intCast(c_int, nc.channel_g(start)), @intCast(c_int, nc.channel_g(end)), duration, diff);
    var b = linear_transition(@intCast(c_int, nc.channel_b(start)), @intCast(c_int, nc.channel_b(end)), duration, diff);
    nc.channel_set_rgb8_clipped(&rgb, r, g, b);
    return rgb;
}

fn transition_box(start: [4]c_int, end: [4]c_int, duration: u64, diff: u64) [4]c_int {
    var coords: [4]c_int = undefined;
    {
        var i: usize = 0;
        while (i < coords.len) : (i += 1) {
            coords[i] = linear_transition(start[i], end[i], duration, diff);
        }
    }
    return coords;
}

fn make_boxes_start(dimy: anytype, dimx: anytype) [BOX_NUM][4]c_int {
    var bs: [BOX_NUM][4]c_int = undefined;
    {
        var i: usize = 0;
        while (i < bs.len) : (i += 1) {
            var y: c_int = -1;
            var x: c_int = @divTrunc(dimx, 2);
            bs[i][0] = y;
            bs[i][1] = x;
            bs[i][2] = y + 2;
            bs[i][3] = x + 4;
        }
    }
    return bs;
}

fn make_boxes_bottom_out(dimy: anytype, dimx: anytype) [BOX_NUM][4]c_int {
    var bs: [BOX_NUM][4]c_int = undefined;
    {
        var i: usize = 0;
        while (i < bs.len) : (i += 1) {
            var y: c_int = (dimy + 4);
            var x: c_int = @divTrunc(dimx, 2);
            bs[i][0] = y;
            bs[i][1] = x;
            bs[i][2] = y + 2;
            bs[i][3] = x + 4;
        }
    }
    return bs;
}

fn make_boxes_arranged(dimy: anytype, dimx: anytype) [BOX_NUM][4]c_int {
    var x0: c_int = 2;
    var x1 = @divFloor(dimx * 40, 100);
    var x2 = @divFloor(dimx * 55, 100);
    var x3 = @divFloor(dimx * 85, 100);
    var x4 = dimx;
    var y0: c_int = 1;
    var y1 = @divFloor(dimy * 18, 100);
    var y2 = @divFloor(dimy * 22, 100);
    var y3 = @divFloor(dimy * 35, 100);
    var y4 = @divFloor(dimy * 55, 100);
    var y5 = @divFloor(dimy * 70, 100);
    var y6 = dimy;
    var bs = [BOX_NUM][4]c_int{ .{ y0, x0, y5, x1 }, .{ y5, x0, y6, x1 }, .{ y0, x1, y2, x2 }, .{ y2, x1, y5, x2 }, .{ y5, x1, y6, x2 }, .{ y0, x2, y3, x3 }, .{ y3, x2, y4, x3 }, .{ y4, x2, y6, x4 }, .{ y0, x3, y1, x4 }, .{ y1, x3, y4, x4 } };
    return bs;
}

fn make_boxes_grid(dimy: anytype, dimx: anytype) [BOX_NUM][4]c_int {
    const boxh: c_int = @divTrunc(dimy, 5);
    const boxw: c_int = (boxh * 2);
    var y0 = @divFloor(dimy * 20, 100);
    var x0 = @divFloor(dimx * 20, 100);
    var bs: [BOX_NUM][4]c_int = undefined;
    {
        var i: usize = 0;
        while (i < bs.len) : (i += 1) {
            const row: c_int = @divFloor(@intCast(c_int, i), 5);
            const col: c_int = @mod(@intCast(c_int, i), 5);
            const shifted = (@mod(col, 2) == 0);
            const y = (y0 + (row * (boxh + @divTrunc(boxh, 2))) + if (shifted) @divTrunc(boxh, 2) + 1 else 0);
            const x = (x0 + (col * (boxw + 2)));
            bs[i][0] = y;
            bs[i][1] = x;
            bs[i][2] = y + boxh;
            bs[i][3] = x + boxw;
        }
    }
    return bs;
}

fn box_ylen(box: [4]c_int) c_int {
    return (box[2] - box[0] - 1);
}

fn box_xlen(box: [4]c_int) c_int {
    return (box[3] - box[1] - 2);
}

fn make_box_planes(n: *nc.ncplane, planes: []*nc.ncplane) void {
    {
        var i: usize = 0;
        while (i < planes.len) : (i += 1) {
            var opts = nc.default_ncplane_options;
            opts.rows = 1;
            opts.cols = 1;
            const plane = nc.ncplane_create(n, &opts);
            planes[i] = plane.?;
        }
    }
}

fn draw_boxes_colored(planes: [BOX_NUM]*nc.ncplane) !void {
    {
        var i: usize = 0;
        while (i < planes.len) : (i += 1) {
            var chans: u64 = 0;
            try nc.err(nc.channels_set_bg_rgb(&chans, box_colors[i]));
            const plane = planes[i];
            try nc.err(nc.ncplane_set_base(plane, " ", 0, chans));
            nc.ncplane_erase(plane);
        }
    }
}

fn draw_boxes_gradients(planes: [BOX_NUM]*nc.ncplane) !void {
    {
        var i: usize = 0;
        while (i < planes.len) : (i += 1) {
            const plane = planes[i];
            const ur: u32 = (16777215 | nc.NC_BGDEFAULT_MASK);
            const ul: u32 = (box_colors[i] | @intCast(u32, nc.NC_BGDEFAULT_MASK));
            const lr: u32 = (box_colors[i] | @intCast(u32, nc.NC_BGDEFAULT_MASK));
            const ll: u32 = (0 | nc.NC_BGDEFAULT_MASK);
            try nc.err(nc.ncplane_highgradient(plane, ul, ur, ll, lr, nc.ncplane_dim_y(plane) - 1, nc.ncplane_dim_x(plane) - 1));
        }
    }
}

fn draw_boxes_bordered(planes: [BOX_NUM]*nc.ncplane) !void {
    {
        var i: usize = 0;
        while (i < planes.len) : (i += 1) {
            var plane = planes[i];
            nc.ncplane_erase(plane);
            try nc.err(nc.ncplane_cursor_move_yx(plane, 0, 0));
            _ = nc.ncplane_rounded_box(plane, 0, 0, nc.ncplane_dim_y(plane) - 1, nc.ncplane_dim_x(plane) - 1, 0);
        }
    }
}

fn reposition_plane(plane: *nc.ncplane, box: [4]c_int) !void {
    try nc.err(nc.ncplane_move_yx(plane, box[0], box[1]));
    try nc.err(nc.ncplane_resize_simple(plane, box_ylen(box), box_xlen(box)));
}

fn reposition_planes(planes: [BOX_NUM]*nc.ncplane, boxes: [BOX_NUM][4]c_int) !void {
    {
        var i: usize = 0;
        while (i < planes.len) : (i += 1) {
            try reposition_plane(planes[i], boxes[i]);
        }
    }
}

fn make_message_box(parent: *nc.ncplane, windowy: c_int, windowx: c_int) !*nc.ncplane {
    const l1 = "Notcurses by Nick Black et al";
    const l2 = "Zig lang by Andrew Kelley & community";
    const l3 = "Liz lang & demo by Jakub Dundalek";
    const l4 = "Press q to quit";
    var opts = nc.default_ncplane_options;
    opts.rows = 5 + 2;
    opts.cols = l2.len + 4;
    opts.x = 4;
    opts.y = windowy - opts.rows - 2;
    const plane = nc.ncplane_create(parent, &opts).?;
    var chans: u64 = 0;
    try nc.err(nc.channels_set_bg_rgb(&chans, 0));
    try nc.err(nc.channels_set_bg_alpha(&chans, nc.NCALPHA_BLEND));
    try nc.err(nc.ncplane_set_base(plane, " ", 0, chans));
    var border_chans: u64 = 0;
    try nc.err(nc.channels_set_fg_rgb(&border_chans, c_red));
    _ = nc.ncplane_rounded_box(plane, 0, border_chans, nc.ncplane_dim_y(plane) - 1, nc.ncplane_dim_x(plane) - 1, 0);
    try nc.err(nc.ncplane_putstr_yx(plane, 1, 2, l1));
    try nc.err(nc.ncplane_putstr_yx(plane, 2, 2, l2));
    try nc.err(nc.ncplane_putstr_yx(plane, 3, 2, l3));
    try nc.err(nc.ncplane_putstr_yx(plane, 5, 2, l4));
    return plane;
}

var box_planes: [BOX_NUM]*nc.ncplane = undefined;
var boxes_start: [BOX_NUM][4]c_int = undefined;
var boxes_bottom_out: [BOX_NUM][4]c_int = undefined;
var boxes_grid: [BOX_NUM][4]c_int = undefined;
var boxes_arranged: [BOX_NUM][4]c_int = undefined;
var message_box: *nc.ncplane = undefined;
const step_ns: u64 = (time.NANOSECS_IN_SEC / 60);
const PositionContext = struct {
    from: c_int,
    to: c_int,
};
fn run_transition(ncs: *nc.notcurses, duration: u64, ctx: anytype, render: fn (@TypeOf(ctx), u64, u64) nc.Error!void) !void {
    var time_start: u64 = time.get_time_ns();
    var t: u64 = time_start;
    while (t < (time_start + duration)) : (t = time.get_time_ns()) {
        try render(ctx, t - time_start, duration);
        try nc.err(nc.notcurses_render(ncs));
        time.sleep_until_ns(t + step_ns);
    }
    try render(ctx, duration, duration);
    try nc.err(nc.notcurses_render(ncs));
}

fn run_serial_transition(ncs: *nc.notcurses, duration: u64, render: fn (usize, u64, u64) nc.Error!void) !void {
    {
        var i: usize = 0;
        while (i < BOX_NUM) : (i += 1) {
            try run_transition(ncs, duration, i, render);
        }
    }
}

pub fn main() !void {
    var nc_opts: nc.notcurses_options = nc.default_notcurses_options;
    var ncs: *nc.notcurses = (nc.notcurses_core_init(&nc_opts, null) orelse @panic("notcurses_core_init() failed"));
    defer _ = nc.notcurses_stop(ncs);
    var dimy: c_int = undefined;
    var dimx: c_int = undefined;
    var n: *nc.ncplane = (nc.notcurses_stddim_yx(ncs, &dimy, &dimx) orelse unreachable);
    dimx = std.math.max(dimx, 80);
    dimy = std.math.max(dimy, 25);
    var std_chan: u64 = 0;
    try nc.err(nc.channels_set_bg_rgb(&std_chan, 0));
    try nc.err(nc.ncplane_set_base(n, " ", 0, std_chan));
    make_box_planes(n, &box_planes);
    boxes_start = make_boxes_start(dimy, dimx);
    boxes_bottom_out = make_boxes_bottom_out(dimy, dimx);
    boxes_grid = make_boxes_grid(dimy, dimx);
    boxes_arranged = make_boxes_arranged(dimy, dimx);
    try run_serial_transition(ncs, 3.0E8, struct {
        fn render(i: usize, diff: u64, duration: u64) nc.Error!void {
            try reposition_plane(box_planes[i], transition_box(boxes_start[i], boxes_grid[i], duration, diff));
            try draw_boxes_bordered(box_planes);
        }
    }.render);
    try run_transition(ncs, 1.0E9, {}, struct {
        fn render(ctx: void, diff: u64, duration: u64) nc.Error!void {
            {
                var i: usize = 0;
                while (i < box_planes.len) : (i += 1) {
                    try reposition_plane(box_planes[i], transition_box(boxes_grid[i], boxes_arranged[i], duration, diff));
                }
            }
            try draw_boxes_bordered(box_planes);
        }
    }.render);
    try run_serial_transition(ncs, 1.5E8, struct {
        fn render(i: usize, diff: u64, duration: u64) nc.Error!void {
            const plane = box_planes[i];
            var chans: u64 = 0;
            _ = nc.channels_set_bchannel(&chans, transition_rgb(3355443, 0, duration, diff));
            _ = nc.channels_set_fchannel(&chans, transition_rgb(15921906, 0, duration, diff));
            try nc.err(nc.ncplane_set_base(plane, " ", 0, chans));
            try draw_boxes_bordered(box_planes);
        }
    }.render);
    try run_serial_transition(ncs, 1.5E8, struct {
        fn render(i: usize, diff: u64, duration: u64) nc.Error!void {
            const plane = box_planes[i];
            var chans: u64 = 0;
            _ = nc.channels_set_bchannel(&chans, transition_rgb(0, box_colors[i], duration, diff));
            try nc.err(nc.ncplane_set_base(plane, " ", 0, chans));
            nc.ncplane_erase(plane);
        }
    }.render);
    try run_serial_transition(ncs, 1.5E8, struct {
        fn render(i: usize, diff: u64, duration: u64) nc.Error!void {
            const plane = box_planes[i];
            const ur: u32 = (transition_rgb(box_colors[i], 16777215, duration, diff) | @intCast(u32, nc.NC_BGDEFAULT_MASK));
            const ul: u32 = (box_colors[i] | @intCast(u32, nc.NC_BGDEFAULT_MASK));
            const lr: u32 = (box_colors[i] | @intCast(u32, nc.NC_BGDEFAULT_MASK));
            const ll: u32 = (transition_rgb(box_colors[i], 0, duration, diff) | @intCast(u32, nc.NC_BGDEFAULT_MASK));
            try nc.err(nc.ncplane_highgradient(plane, ul, ur, ll, lr, nc.ncplane_dim_y(plane) - 1, nc.ncplane_dim_x(plane) - 1));
        }
    }.render);
    message_box = (try make_message_box(n, dimy, dimx));
    try run_transition(ncs, 3.0E8, PositionContext{
        .from = (-nc.ncplane_dim_x(message_box)),
        .to = nc.ncplane_x(message_box),
    }, struct {
        fn render(ctx: PositionContext, diff: u64, duration: u64) nc.Error!void {
            const x: c_int = linear_transition(ctx.from, ctx.to, duration, diff);
            try nc.err(nc.ncplane_move_yx(message_box, nc.ncplane_y(message_box), x));
        }
    }.render);
    outer: {
        var loop: usize = 0;
        while (true) : (loop += 1) {
            var duration: u64 = 1.0E9;
            var time_start: u64 = time.get_time_ns();
            var t: u64 = time_start;
            while (t < (time_start + duration)) : (t = time.get_time_ns()) {
                {
                    var i: usize = 0;
                    while (i < box_planes.len) : (i += 1) {
                        var plane = box_planes[i];
                        var i_next = ((i + 1) % BOX_NUM);
                        const colors = [4]u32{ box_colors[i], 16777215, box_colors[i], 0 };
                        var corners: [4]u32 = undefined;
                        {
                            var j: usize = 0;
                            while (j < 4) : (j += 1) {
                                corners[j] = @intCast(u32, nc.NC_BGDEFAULT_MASK) | transition_rgb(colors[((loop + j) % 4)], colors[((j + loop + 1) % 4)], duration, t - time_start);
                            }
                        }
                        try nc.err(nc.ncplane_highgradient(plane, corners[0], corners[1], corners[3], corners[2], nc.ncplane_dim_y(plane) - 1, nc.ncplane_dim_x(plane) - 1));
                    }
                }
                try nc.err(nc.notcurses_render(ncs));
                time.sleep_until_ns(t + step_ns);
                var keypress: c_uint = nc.notcurses_getc_nblock(ncs, null);
                if (keypress == 'q') {
                    break :outer;
                }
            }
        }
    }
}

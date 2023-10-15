const time = @cImport({
    @cInclude("time.h");
});
pub const NANOSECS_IN_SEC = 1000000000;
pub fn timespec_to_ns(ts: *time.timespec) c_long {
    return ((ts.tv_sec * NANOSECS_IN_SEC) + ts.tv_nsec);
}

pub fn ns_to_timespec(ns: anytype, ts: *time.timespec) void {
    ts.tv_sec = @as(c_long, @intCast(@divTrunc(ns, NANOSECS_IN_SEC)));
    ts.tv_nsec = @as(c_long, @intCast(ns % NANOSECS_IN_SEC));
}

pub fn get_time_ns() u64 {
    var now: time.timespec = undefined;
    _ = time.clock_gettime(time.CLOCK_MONOTONIC, &now);
    return @as(u64, @intCast(timespec_to_ns(&now)));
}

pub fn sleep_until_ns(ns: u64) void {
    var sleepspec: time.timespec = undefined;
    ns_to_timespec(ns, &sleepspec);
    _ = time.clock_nanosleep(time.CLOCK_MONOTONIC, time.TIMER_ABSTIME, &sleepspec, null);
}

pub fn sleep_ns(ns: u64) void {
    sleep_until_ns(get_time_ns() + ns);
}

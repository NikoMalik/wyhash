const std = @import("std");
const builtin = @import("builtin");

const ptr: *const u8 = undefined;
const uintptr = usize;

const _wyp0 = 0xa0761d6478bd642f;
const _wyp1 = 0xe7037ed1a0b428db;
const _wyp2 = 0x8ebc6af09c88c6e3;
const _wyp3 = 0x589965cc75374cc3;
const _wyp4 = 0x1d8e4e27c47d124f;

inline fn off(p: [*]const u8, offset: usize) [*]const u8 {
    return @ptrFromInt(@intFromPtr(p) + offset);
}

inline fn wyrot(x: u64) u64 {
    return (x >> 32) | (x << 32);
}

inline fn wymum(x: *u64, y: *u64) void {
    if (comptime builtin.target.cpu.arch == .x86_64) {
        const x_val = x.*;
        const y_val = y.*;
        var lo: u64 = undefined;
        var hi: u64 = undefined;

        asm volatile (
            \\mulq %[y_val]
            : [lo] "={rax}" (lo),
              [hi] "={rdx}" (hi),
            : [x_val] "{rax}" (x_val),
              [y_val] "r" (y_val),
            : .{ .cc = true });

        x.* = lo;
        y.* = hi;
    } else {
        const product = @as(u128, x.*) * @as(u128, y.*);
        x.* = @truncate(product);
        y.* = @truncate(product >> 64);
    }
}

inline fn _wmum(a: u64, b: u64) u64 {
    var a_copy = a;
    var b_copy = b;

    wymum(&a_copy, &b_copy);

    return a_copy ^ b_copy;
}

inline fn wyr1(p: [*]const u8) u64 {
    return @as(u64, p[0]);
}

inline fn wyr2(p: [*]const u8) u64 {
    return @as(u64, p[0]) | (@as(u64, p[1]) << 8);
}

inline fn wyr3(p: [*]const u8, k: usize) u64 {
    const b0 = @as(u64, @intFromPtr(p));
    const b1 = @as(u64, @intFromPtr(off(p, k >> 1)));
    const b2 = @as(u64, @intFromPtr(off(p, k - 1)));

    return b0 << 16 | b1 << 8 | b2;
}

inline fn wyr4(p: [*]const u8) u64 {
    return @as(u64, p[0]) |
        (@as(u64, p[1]) << 8) |
        (@as(u64, p[2]) << 16) |
        (@as(u64, p[3]) << 24);
}

inline fn wyr8(p: [*]const u8) u64 {
    return @as(u64, p[0]) |
        (@as(u64, p[1]) << 8) |
        (@as(u64, p[2]) << 16) |
        (@as(u64, p[3]) << 24) |
        (@as(u64, p[4]) << 32) |
        (@as(u64, p[5]) << 40) |
        (@as(u64, p[6]) << 48) |
        (@as(u64, p[7]) << 56);
}

inline fn _wyr9(p: [*]const u8) u64 {
    const bytes = @as(*const [8]u8, @ptrCast(p));

    const lo = @as(u32, bytes[0]) | (@as(u32, bytes[1]) << 8) | (@as(u32, bytes[2]) << 16) | (@as(u32, bytes[3]) << 24);

    const hi = @as(u32, bytes[4]) | (@as(u32, bytes[5]) << 8) | (@as(u32, bytes[6]) << 16) | (@as(u32, bytes[7]) << 24);

    return (@as(u64, lo) << 32) | @as(u64, hi);
}

pub inline fn _wx64(key: u64) u64 {
    const p: [*]const u8 = @ptrCast(&key);
    const a: u64 = wyr8(p);
    return _wmum(_wmum(a ^ key ^ _wyp0, a ^ key ^ _wyp1) ^ key, 8 ^ _wyp4);
}

pub inline fn _wx32(key: u32) u64 {
    const p: [*]const u8 = @ptrCast(&key);
    const key64: u64 = @intCast(key);
    const a: u64 = wyr4(p);
    return _wmum(_wmum(a ^ key64 ^ _wyp0, a ^ key64 ^ _wyp1) ^ key64, 4 ^ _wyp4);
}

pub inline fn _wx8(key: u8) u64 {
    // const p: [*]const u8 = @ptrCast(&key);
    const a: u64 = @intCast(key);
    const key64: u64 = @intCast(key);

    return _wmum(_wmum(a ^ key64 ^ _wyp0, key64 ^ _wyp1) ^ key64, 1 ^ _wyp4);
}

pub inline fn _wx16(key: u16) u64 {
    const p: [*]const u8 = @ptrCast(&key);
    const key64: u64 = @intCast(key);
    const a: u64 = wyr2(p);

    return _wmum(_wmum(a ^ key64 ^ _wyp0, a ^ key64 ^ _wyp1) ^ key64, 2 ^ _wyp4);
}

pub inline fn _whash(data: []const u8, seed: u64) u64 {
    var p: [*]const u8 = data.ptr;
    const len: usize = data.len;
    var offset: usize = data.len;

    var seed_var = seed;
    var see1 = seed;

    if (len <= 0x03) {
        return _wmum(_wmum(wyr3(p, len) ^ seed_var ^ _wyp0, seed_var ^ _wyp1) ^ seed_var, @as(u64, len) ^ _wyp4);
    } else if (len <= 0x08) {
        return _wmum(_wmum(wyr4(off(p, 0x00)) ^ seed_var ^ _wyp0, wyr4(off(p, len - 0x04)) ^ seed_var ^ _wyp1) ^ seed_var, @as(u64, len) ^ _wyp4);
    } else if (len <= 0x10) {
        return _wmum(_wmum(_wyr9(off(p, 0x00)) ^ seed_var ^ _wyp0, _wyr9(off(p, len - 0x08)) ^ seed_var ^ _wyp1) ^ seed_var, @as(u64, len) ^ _wyp4);
    } else if (len <= 0x18) {
        return _wmum(_wmum(_wyr9(off(p, 0x00)) ^ seed_var ^ _wyp0, _wyr9(off(p, 0x08)) ^ seed_var ^ _wyp1) ^ _wmum(_wyr9(off(p, len - 0x08)) ^ seed_var ^ _wyp2, seed_var ^ _wyp3), @as(u64, len) ^ _wyp4);
    } else if (len <= 0x20) {
        return _wmum(_wmum(_wyr9(off(p, 0x00)) ^ seed_var ^ _wyp0, _wyr9(off(p, 0x08)) ^ seed_var ^ _wyp1) ^ _wmum(_wyr9(off(p, 0x10)) ^ seed_var ^ _wyp2, _wyr9(off(p, len - 0x08)) ^ seed_var ^ _wyp3), @as(u64, len) ^ _wyp4);
    } else if (len <= 0x100) {
        seed_var = _wmum(wyr8(off(p, 0x00)) ^ seed_var ^ _wyp0, wyr8(off(p, 0x08)) ^ seed_var ^ _wyp1);
        see1 = _wmum(wyr8(off(p, 0x10)) ^ see1 ^ _wyp2, wyr8(off(p, 0x18)) ^ see1 ^ _wyp3);

        if (len > 0x40) {
            seed_var = _wmum(wyr8(off(p, 0x20)) ^ seed_var ^ _wyp0, wyr8(off(p, 0x28)) ^ seed_var ^ _wyp1);
            see1 = _wmum(wyr8(off(p, 0x30)) ^ see1 ^ _wyp2, wyr8(off(p, 0x38)) ^ see1 ^ _wyp3);
        }
        if (len > 0x60) {
            seed_var = _wmum(wyr8(off(p, 0x40)) ^ seed_var ^ _wyp0, wyr8(off(p, 0x48)) ^ seed_var ^ _wyp1);
            see1 = _wmum(wyr8(off(p, 0x50)) ^ see1 ^ _wyp2, wyr8(off(p, 0x58)) ^ see1 ^ _wyp3);
        }
        if (len > 0x80) {
            seed_var = _wmum(wyr8(off(p, 0x60)) ^ seed_var ^ _wyp0, wyr8(off(p, 0x68)) ^ seed_var ^ _wyp1);
            see1 = _wmum(wyr8(off(p, 0x70)) ^ see1 ^ _wyp2, wyr8(off(p, 0x78)) ^ see1 ^ _wyp3);
        }
        if (len > 0xa0) {
            seed_var = _wmum(wyr8(off(p, 0x80)) ^ seed_var ^ _wyp0, wyr8(off(p, 0x88)) ^ seed_var ^ _wyp1);
            see1 = _wmum(wyr8(off(p, 0x90)) ^ see1 ^ _wyp2, wyr8(off(p, 0x98)) ^ see1 ^ _wyp3);
        }

        if (len > 0xc0) {
            seed_var = _wmum(wyr8(off(p, 0xa0)) ^ seed_var ^ _wyp0, wyr8(off(p, 0xa8)) ^ seed_var ^ _wyp1);
            see1 = _wmum(wyr8(off(p, 0xb0)) ^ see1 ^ _wyp2, wyr8(off(p, 0xb8)) ^ see1 ^ _wyp3);
        }
        if (len > 0xe0) {
            seed_var = _wmum(wyr8(off(p, 0xc0)) ^ seed_var ^ _wyp0, wyr8(off(p, 0xc8)) ^ seed_var ^ _wyp1);
            see1 = _wmum(wyr8(off(p, 0xd0)) ^ see1 ^ _wyp2, wyr8(off(p, 0xd8)) ^ see1 ^ _wyp3);
        }
        offset = (offset - 1) % 0x20 + 1;
        p = off(p, len - offset);
    } else {
        while (offset > 0x100) : ({
            offset -= 0x100;
            p = off(p, 0x100);
        }) {
            seed_var = _wmum(wyr8(off(p, 0x00)) ^ seed_var ^ _wyp0, wyr8(off(p, 0x08)) ^ seed_var ^ _wyp1) ^ _wmum(wyr8(off(p, 0x10)) ^ seed_var ^ _wyp2, wyr8(off(p, 0x18)) ^ seed_var ^ _wyp3);
            see1 = _wmum(wyr8(off(p, 0x20)) ^ see1 ^ _wyp1, wyr8(off(p, 0x28)) ^ see1 ^ _wyp2) ^ _wmum(wyr8(off(p, 0x30)) ^ see1 ^ _wyp3, wyr8(off(p, 0x38)) ^ see1 ^ _wyp0);

            seed_var = _wmum(wyr8(off(p, 0x40)) ^ seed_var ^ _wyp0, wyr8(off(p, 0x48)) ^ seed_var ^ _wyp1) ^ _wmum(wyr8(off(p, 0x50)) ^ seed_var ^ _wyp2, wyr8(off(p, 0x58)) ^ seed_var ^ _wyp3);
            see1 = _wmum(wyr8(off(p, 0x60)) ^ see1 ^ _wyp1, wyr8(off(p, 0x68)) ^ see1 ^ _wyp2) ^ _wmum(wyr8(off(p, 0x70)) ^ see1 ^ _wyp3, wyr8(off(p, 0x78)) ^ see1 ^ _wyp0);

            seed_var = _wmum(wyr8(off(p, 0x80)) ^ seed_var ^ _wyp0, wyr8(off(p, 0x88)) ^ seed_var ^ _wyp1) ^ _wmum(wyr8(off(p, 0x90)) ^ seed_var ^ _wyp2, wyr8(off(p, 0x98)) ^ seed_var ^ _wyp3);
            see1 = _wmum(wyr8(off(p, 0xa0)) ^ see1 ^ _wyp1, wyr8(off(p, 0xa8)) ^ see1 ^ _wyp2) ^ _wmum(wyr8(off(p, 0xb0)) ^ see1 ^ _wyp3, wyr8(off(p, 0xb8)) ^ see1 ^ _wyp0);

            seed_var = _wmum(wyr8(off(p, 0xc0)) ^ seed_var ^ _wyp0, wyr8(off(p, 0xc8)) ^ seed_var ^ _wyp1) ^ _wmum(wyr8(off(p, 0xd0)) ^ seed_var ^ _wyp2, wyr8(off(p, 0xd8)) ^ seed_var ^ _wyp3);
            see1 = _wmum(wyr8(off(p, 0xe0)) ^ see1 ^ _wyp1, wyr8(off(p, 0xe8)) ^ see1 ^ _wyp2) ^ _wmum(wyr8(off(p, 0xf0)) ^ see1 ^ _wyp3, wyr8(off(p, 0xf8)) ^ see1 ^ _wyp0);
        }

        while (offset > 0x20) : ({
            offset = offset - 0x20;
            p = off(p, 0x20);
        }) {
            seed_var = _wmum(wyr8(off(p, 0x00)) ^ seed_var ^ _wyp0, wyr8(off(p, 0x08)) ^ seed_var ^ _wyp1) ^ _wmum(wyr8(off(p, 0x10)) ^ seed_var ^ _wyp2, wyr8(off(p, 0x18)) ^ seed_var ^ _wyp1);
            see1 = _wmum(wyr8(off(p, 0x10)) ^ see1 ^ _wyp2, wyr8(off(p, 0x18)) ^ see1 ^ _wyp3) ^ _wmum(wyr8(off(p, 0x30)) ^ see1 ^ _wyp0, wyr8(off(p, 0x18)) ^ see1 ^ _wyp3);
        }
    }

    if (offset > 0x18) {
        seed_var = _wmum(_wyr9(off(p, 0x00)) ^ seed_var ^ _wyp0, _wyr9(off(p, 0x08)) ^ seed_var ^ _wyp1);
        see1 = _wmum(_wyr9(off(p, 0x10)) ^ see1 ^ _wyp2, _wyr9(off(p, 0x18)) ^ see1 ^ _wyp3);
    }
    if (offset > 0x10) {
        seed_var = _wmum(_wyr9(off(p, 0x00)) ^ seed_var ^ _wyp0, _wyr9(off(p, 0x08)) ^ seed_var ^ _wyp1);
        see1 = _wmum(_wyr9(off(p, offset - 0x08)) ^ see1 ^ _wyp2, see1 ^ _wyp3);
    }
    if (offset > 0x08) {
        seed_var = _wmum(_wyr9(off(p, 0x00)) ^ seed_var ^ _wyp0, _wyr9(off(p, offset - 0x08)) ^ seed_var ^ _wyp1);
    }

    if (offset > 0x03) {
        seed_var = _wmum(wyr3(p, offset) ^ seed_var ^ _wyp0, seed_var ^ _wyp1);
    } else {
        seed_var = _wmum(wyr3(p, offset) ^ seed_var ^ _wyp0, seed_var ^ _wyp1);
    }

    return _wmum(seed_var ^ see1, @as(u64, len) ^ _wyp4);
}

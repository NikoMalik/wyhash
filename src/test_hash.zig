const wx = @import("hash.zig");
const std = @import("std");

//zig test test_hash.zig
test "wx64 basic test" {
    const key: u64 = 0xdeadbeefdeadbeef;

    const result = wx._wx64(key);
    std.debug.print("wx64({}) = {}\n", .{ key, result });

    try std.testing.expect(result != 0);
}

test "_whash hash 3 bytes" {
    const key = "abc";
    const result = wx._whash(key[0..], 42);

    std.debug.print("wx64('abc') = {}\n", .{result});
    try std.testing.expect(result != 0);
}

test "_whash hash 8 bytes" {
    const key = "aaaaaaaa";
    const result = wx._whash(key[0..], 42);
    std.debug.print("wx64('aaaaaaaa') = {}\n", .{result});
    try std.testing.expect(result != 0);
}

test "_whash hash 16 bytes" {
    const key = "aaaaaaaaaaaaaaaa";
    const result = wx._whash(key[0..], 42);
    std.debug.print("wx64('aaaaaaaaaaaaaaaa') = {}\n", .{result});
    try std.testing.expect(result != 0);
}

test "data of size 4 to 8 bytes" {
    const data = "abcd";
    const result = wx._whash(data[0..], 0xdeadbeef);

    try std.testing.expect(result != 0);
}

test "data of size 9 to 16 bytes" {
    const data = "abcdefghijklmno";
    const result = wx._whash(data[0..], 0xdeadbeef);

    std.debug.print("wx64('abcdefghijklmno') = {}\n", .{result});
    try std.testing.expect(result != 0);
}

test "data larger than 16 bytes" {
    const data = "a" ** 100; // 100 bytes of data
    const result = wx._whash(data[0..], 0xdeadbeef);

    std.debug.print("wx64('a' * 100) = {}\n", .{result});
    try std.testing.expect(result != 0);
}

test "large data" {
    const data = "a" ** 1024; // 1024 bytes of data
    const result = wx._whash(data[0..], 0xdeadbeef);
    std.debug.print("wx64('a' * 1024) = {}\n", .{result});
    try std.testing.expect(result != 0);
}

test "different seeds" {
    const data = "abc";
    const result1 = wx._whash(data[0..], 0xdeadbeef);
    const result2 = wx._whash(data[0..], 0x12345678);
    std.debug.print("wx64('abc', 0xdeadbeef) = {}\n", .{result1});
    std.debug.print("wx64('abc', 0x12345678) = {}\n", .{result2});
    try std.testing.expect(result1 != result2);
}

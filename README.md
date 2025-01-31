# WYHASH - Zig Implementation

![Github Repo Issues](https://img.shields.io/github/issues/NikoMalik/wyhash?style=flat) ![GitHub Repo stars](https://img.shields.io/github/stars/NikoMalik/wyhash?style=social)



🚀 Overview

Wyhash is a fast, high-quality, portable non-cryptographic hash function known for its exceptional speed and randomness quality. 
This repository provides a native Zig implementation of Wyhash.Project is also open for people to add to and improve. Please check the issues to view requested features


Why Wyhash?

✅ Extremely fast performance across different architectures
✅ High-quality randomness and strong avalanche effect
✅ Minimal code size and efficient memory usage
✅ Used in databases, networking, and high-performance applications



# 🛠 Basic Usage

```zig
const wyhash = @import("wyhash");
const std = @import("std");

pub fn main() !void {
    const r: u64 = 0x001020120;

    const res = wyhash._whash("🔥Hello World!", r);
    std.debug.print("wyhash(\"🔥Hello World!\", {}) = {}\n", .{ r, res });
}

```

# 📦 Installation

*Add this to your build.zig.zon*

```zig
.dependencies = .{
    .wyhash = .{
        .url = "https://github.com/NikoMalik/wyhash/archive/refs/heads/main.tar.gz",
        //the correct hash will be suggested by zig
    }
}

```

*And add this to you build.zig*

```zig
    const wyhash = b.dependency("wyhash", .{
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("wyhash", wyhash.module("wyhash"));


```

#  📦 Installation/2

```bash

git clone https://github.com/NikoMalik/wyhash.git
mv wyhash /path/to/your/project/directory
```



You can then import the library into your code like this

```zig
const wyhash = @import("wyhash")
```



# 🔥 Benchmarks

Wyhash is one of the fastest hash functions available. Benchmarks against MurmurHash3, XXHash, and CityHash show superior performance in most cases.



# 👥 Credits

Original Wyhash: Wang Yi

Repo: https://github.com/wangyi-fudan/wyhash



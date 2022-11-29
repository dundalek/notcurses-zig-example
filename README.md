
# Notcurses Zig example

[Notcurses](https://notcurses.com/) is a moderm library for building terminal UIs with advanced graphics support.

This is a demo showing how to use it with [Zig](https://ziglang.org/) programming language.  
Thanks to Zig's seamless C interop the library can be used directly without wrapper bindings.

![Notcurses Zig demo](https://user-images.githubusercontent.com/755611/114319180-d83ac400-9aff-11eb-8b50-3e9a388b91c7.png)

### Dependencies
- Install [Notcurses dependencies](https://github.com/dankamongmen/notcurses/blob/master/INSTALL.md)
  - using [Nix](https://nixos.org/):  
  `nix-shell`
  - for Debian/Ubuntu:  
  `sudo apt-get install build-essential cmake libncurses-dev libreadline-dev libunistring-dev libqrcodegen-dev zlib1g-dev`
- [Install Zig](https://ziglang.org/download/) (version 0.9.1+)
- Get Notcurses to compile from sources (since distributions don't often package latest versions):
```sh
git clone https://github.com/dankamongmen/notcurses.git deps/notcurses
cd deps/notcurses
mkdir build && cd build
cmake -DUSE_MULTIMEDIA=none -DUSE_PANDOC=OFF ..
# We just need `cmake` to generate some headers, no need to actually `make` since rest will be handled by Zig
# In case of errors, try `git checkout v3.0.8` and re-run cmake as I tested it with this version.
```

### Build and run

Build and run the demo:
```sh
zig build run
```

Or build and run the binary separately:
```sh
zig build
./zig-cache/run/demo
```

### Liz source

The source of this demo is actually written in [Liz](https://github.com/dundalek/liz), which is Zig dialect with [lispy syntax](https://en.m.wikipedia.org/wiki/S-expression) that transpiles down to Zig code. If you feel adventurous to explore land of parentheses you can  [download Liz](https://github.com/dundalek/liz/releases/latest) and compile sources with:

```sh
liz src/*.liz && zig build
```

### Related

See also the demo implemented in [Clojure](https://github.com/dundalek/notcurses-clojure-example).

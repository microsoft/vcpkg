# Manual Integration

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/buildsystems/manual-integration.md).**

When installing libraries, vcpkg creates a single common layout partitioned by triplet. 

The root of the tree in classic mode is `[vcpkg root]/installed`. The root of the tree in manifest mode is `[vcpkg.json directory]/vcpkg_installed`.

Underneath this root, in a subfolder named after the triplet:

* Header files: `include/`
* Release `.lib`, `.a`, and `.so` files: `lib/` or `lib/manual-link/`
* Release `.dll` files: `bin/`
* Release `.pc` files: `lib/pkgconfig/`
* Debug `.lib`, `.a`, and `.so` files: `debug/lib/` or `debug/lib/manual-link/`
* Debug `.dll` files: `debug/bin/`
* Debug `.pc` files: `debug/lib/pkgconfig/`
* Tools: `tools/[portname]/`

For example, `zlib.h` for `zlib:x64-windows` in classic mode is located at `[vcpkg root]/installed/x64-windows/include/zlib.h`.

See your build system specific documentation for how to use prebuilt binaries. For example, `Makefile` projects often accept environment variables:

```sh
export CXXFLAGS=-I$(pwd)/installed/x64-linux/include
export CFLAGS=-I$(pwd)/installed/x64-linux/include
export LDFLAGS=-L$(pwd)/installed/x64-linux/lib
export PKG_CONFIG_PATH=$(pwd)/installed/x64-linux/lib/pkgconfig:$PKG_CONFIG_PATH
```

_On Windows dynamic triplets, such as x64-windows:_ To run any produced executables you will also need to either copy the needed DLL files to the same folder as your executable or *prepend* the correct `bin\` directory to your path.

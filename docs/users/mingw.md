# Vcpkg and Mingw-w64

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/mingw.md).**

*MinGW is community-supported and not tested as part of vcpkg repository's CI process.*

## Table of Contents

 - [Mingw-w64 community triplets](#Mingw-w64-community-triplets)
 - [Using Mingw-w64 natively on Windows](#Using-Mingw-w64-natively-on-Windows)
   - [How to avoid mixing different installations](#How-to-avoid-mixing-different-installations)
 - [Using Mingw-w64 to build Windows programs on other systems](#Using-Mingw-w64-to-build-Windows-programs-on-other-systems)

## Mingw-w64 community triplets

Vcpkg includes
[x64, x86, arm64 and arm community triplets](https://github.com/microsoft/vcpkg/tree/master/triplets/community)
for [Mingw-w64](http://mingw-w64.org/). They don't depend on Visual Studio and
can be used natively on Windows as well as for cross-compiling on
other operating systems. There are two variants of each triplet,
selecting between static and dynamic linking. The actual tools
(g++ etc.) are expected to be named with particular prefixes.

| architecture | vcpkg community triplets                | tool name prefix     |
|--------------|-----------------------------------------|----------------------|
| x64          | x64-mingw-dynamic, x64-mingw-static     | x86_64-w64-mingw32-  |
| x86          | x86-mingw-dynamic, x86-mingw-static     | i686-w64-mingw32-    |
| arm64        | arm64-mingw-dynamic, arm64-mingw-static | aarch64-w64-mingw32- |
| arm          | arm-mingw-dynamic, arm-mingw-static     | armv7-w64-mingw32-   |

These triplets are not tested by continuous integration, so many ports
do not build, and even existing ports may break on port updates.
Because of this, community involvement is paramount!

- [Discussions](https://github.com/microsoft/vcpkg/discussions?discussions_q=mingw)
- [Open issues](https://github.com/microsoft/vcpkg/issues?q=is%3Aissue+is%3Aopen+mingw)
- [Open pull requests](https://github.com/microsoft/vcpkg/pulls?q=is%3Apr+is%3Aopen+mingw)

## Using Mingw-w64 natively on Windows

With [MSYS2](https://www.msys2.org/), it is possible to easily create
a full environment for building ports with Mingw-w64 on a Windows PC.

Note that for building software for native windows environments, you
must use a mingw subsystem of MSYS2, and install some packages 
(with a specific prefix) for this subsystem.

| architecture | vcpkg triplets                      | subsystem | package prefix    |
|--------------|-------------------------------------|-----------|-------------------|
| x64          | x64-mingw-dynamic, x64-mingw-static | mingw64   | mingw-w64-x86_64- |
| x86          | x86-mingw-dynamic, x86-mingw-static | mingw32   | mingw-w64-i686-   |

After the basic installation of MSYS2, you will need to install a few
additional packages for software development, e.g. for x64:

```bash
pacman -S --needed git base-devel mingw-w64-x86_64-toolchain
```

The active subsystem is selected by running the MSYS2 MinGW app, or
changed in a running terminal by

```bash
source shell mingw64   # for x64, or "mingw32" for x86
```

The bootstrapping of vcpkg shall be done by running bootstrap-vcpkg.bat.
This will download the official vcpkg.exe.

```bash
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.bat
```

For building packages, you need to tell vcpkg that you want to use the
mingw triplet. This can be done in different ways. When Visual Studio
is not installed, you must also set the host triplet to mingw. This is
needed to resolve host dependencies. For convenience, you can use
environment variables to set both triplets:

```bash
export VCPKG_DEFAULT_TRIPLET=x64-mingw-dynamic
export VCPKG_DEFAULT_HOST_TRIPLET=x64-mingw-dynamic
```

Now you can test your setup:

```bash
./vcpkg install zlib
```

### How to avoid mixing different installations

[The MSYS2 project explicitly warns](https://www.msys2.org/wiki/MSYS2-introduction/#path)
that "mixing in programs from other MSYS2 installations, Cygwin installations,
compiler toolchains or even various other programs is not supported and will
probably break things in unexpected ways." For example, the proper passing of
command line arguments with quoting and escaping may fail.

But Vcpkg ports implicitly create MSYS2 installations, e.g. for `pkg-config`
and for various other build tools needed to deal with packages based on
autoconf. In particular, when ports prepend the directory of tools to the
`PATH` environment variable, this may change which tool with a particular
name is actually invoked, and how arguments are passed between tools.

To mitigate such issues when working with a full MSYS2 installation,
try to keep the directories of the msys subsystem (`/usr/bin`, `bin`)
out of the `PATH` environment variable as found by vcpkg. In bash, you
may modify the `PATH` just for a single call of vcpkg:

```bash
PATH="${PATH/:\/usr\/bin:\/bin:/:}" ./vcpkg install libpq
```

Alternatively, you may run vcpkg from a regular Command Prompt, after
adding *only* the desired mingw directory (e.g. `C:\msys64\mingw64\bin`)
to the `PATH`.

When using vcpkg for CI with standard images on Azure Pipelines, Github Actions
or similar, note that the default `PATH` might contain more directories
which create a mix of MSYS2 programs from different installations. You may
want to set the desired `PATH` manually, or remove directories which contain
`sh.exe`, `bash.exe`, `msys-2.0.dll` or `cygwin1.dll`.

## Using Mingw-w64 to build Windows programs on other systems

You can use the vcpkg mingw community triplets with toolchains on
non-Windows computers to cross-compile software to be run on Windows.
Many Linux distributions offer such toolchains in optional packages
with a mingw-w64 [suffix](https://repology.org/projects/?search=-mingw-w64)
or [prefix](https://repology.org/projects/?search=mingw-w64-).
As an example, for Debian-based distributions, you would start with
this installation command for the x64 toolchain:

```
sudo apt-get install gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64
```

Note that the packaged versions of Mingw-w64 toolchains on Linux distributions
might be older releases which lack some useful features or bug fixes.
An alternative independent toolchain is offered by [MXE](https://mxe.cc/).

For vcpkg bootstrapping, clone the github repository and run the
`bootstrap-vcpkg.sh` script:

```bash
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.sh
./vcpkg install zlib:x64-mingw-dynamic
```


# Vcpkg and MinGW

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/mingw.md).**

## MinGW community triplets

vcpkg includes
[community triplets for MinGW](https://github.com/microsoft/vcpkg/tree/master/triplets/community)
for x64, x86, arm64 and arm. They don't depend on Visual Studio and
can be used natively on Windows as well as for cross-compiling on
other operating systems. There are two variants of each triplet,
selecting between static and dynamic linking:

- arm64-mingw-dynamic
- arm64-mingw-static
- arm-mingw-dynamic
- arm-mingw-static
- x64-mingw-dynamic
- x64-mingw-static
- x86-mingw-dynamic
- x86-mingw-static

These triplets are not tested by continuous integration, so many ports
do not build, and even existing ports may break on port updates.
Because of this, community involvement is paramount!

- [Discussions](https://github.com/microsoft/vcpkg/discussions?discussions_q=mingw)
- [Open issues](https://github.com/microsoft/vcpkg/issues?q=is%3Aissue+is%3Aopen+mingw)
- [Open pull requests](https://github.com/microsoft/vcpkg/pulls?q=is%3Apr+is%3Aopen+mingw)

## Using MinGW natively on Windows

With [MSYS2](https://www.msys2.org/), it is possible to easily create
a full environment for building ports with MinGW on a Windows PC.

Note that for building software for native windows environments, you
must use a mingw subsystem of MSYS2, and install some packages 
(with a specific prefix) for this subsystem.

| architecture | vcpkg triplets                      | subsystem | package prefix    |
|--------------|-------------------------------------|-----------|-------------------|
| x64          | x64-mingw-dynamic, x64-mingw-static | mingw64   | mingw-w64-x86_64- |
| x86          | x86-mingw-dynamic, x86-mingw-static | mingw32   | mingw-w64-i686-   |

After the basic installation if MSYS2, you will need to install a few
additional packages for software development, e.g. for x64:

```bash
pacman -S git mingw-w64-x86_64-cmake mingw-w64-x86_64-ninja
```

The active subsystem is select by running the MSYS2 MinGW app, or
changed in a running terminal by

```bash
source shell mingw64   # or mingw32
```

The bootstrapping of vcpkg shall be done by running bootstrap_vcpkg.exe.
This will download the official vcpkg.exe.

```bash
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.bat
```

For building packages, you need to tell vcpkg that you want to use the
MinGW triplet. This can be done in different ways. When Visual Studio
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

## Using MinGW to build Windows programs on other systems

Many Linux distributions come with MinGW toolchains which allow to
cross-compile software on Linux to be run on Windows. You can use
such toolchains with vcpkg by setting the desired mingw triplet.

Note that the pre-installed cmake might be too old for vcpkg.

For bootstrapping, clone the github repository and run the shell script:

```bash
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg
./bootstrap-vcpkg.sh
./vcpkg install zlib:x64-mingw-dynamic
```


# Vcpkg

## Overview
Vcpkg helps you get C and C++ libraries on Windows.

For short description of available commands, run `vcpkg help`.

## Table of Contents
- <a href="#example-1">Example 1: Using the C++ REST SDK</a>
  - <a href="#example-1-1">Step 1: Build</a>
  - <a href="#example-1-2">Step 2: Use</a>
    - <a href="#example-1-2-a">Option A: VS Project (User-wide integration)</a>
    - <a href="#example-1-2-b">Option B: CMake (Toolchain file)</a>
    - <a href="#example-1-2-c">Option C: Other buildsystems</a>
    - <a href="#example-1-2-d">Option D: VS Project (Individual Project integration)</a>
- <a href="#example-2">Example 2: Package a remote project (zlib)</a>

<a name="example-1"></a>
## Example 1: C++ REST SDK
<a name="example-1-1"></a>
### Step 1: Build

First, we need to know what name C++ REST SDK goes by in the ports tree. To do that, we'll run the `search` command and inspect the output:
```
PS D:\src\vcpkg> .\vcpkg search
boost                1.60             Peer-reviewed portable C++ source libraries
cpprestsdk           2.8              C++11 JSON, REST, and OAuth library The C++ RES...
curl                 7.48.0           A library for transferring data with URLs
expat                2.1.1            XML parser library written in C
freetype             2.6.3            A library to render fonts.
glew                 1.13.0           The OpenGL Extension Wrangler Library (GLEW) is a...
glfw3                3.1.2            GLFW is a free, Open Source, multi-platform libra...
libjpeg-turbo        1.4.90-1         libjpeg-turbo is a JPEG image codec that uses SIM...
libpng               1.6.24-1         libpng is a library implementing an interface for...
libuv                1.9.1            libuv is a multi-platform support library with a ...
libwebsockets        2.0.0            Libwebsockets is a lightweight pure C library bui...
mpg123               1.23.3           mpg123 is a real time MPEG 1.0/2.0/2.5 audio play...
openal-soft          1.17.2           OpenAL Soft is an LGPL-licensed, cross-platform, ...
opencv               3.1.0            computer vision library
opengl               10.0.10240.0     Open Graphics Library (OpenGL)[3][4][5] is a cros...
openssl              1.0.2h           OpenSSL is an open source project that provides a...
range-v3             0.0.0-1          Range library for C++11/14/17.
rapidjson            1.0.2-1          A fast JSON parser/generator for C++ with both SA...
sdl2                 2.0.4            Simple DirectMedia Layer is a cross-platform deve...
sqlite3              3120200          SQLite is a software library that implements a se...
tiff                 4.0.6            A library that supports the manipulation of TIFF ...
tinyxml2             3.0.0            A simple, small, efficient, C++ XML parser
zlib                 1.2.8            A compression library
```
Looking at the list, we can see that the port is named "cpprestsdk".

Installing is then as simple as using the `install` command. Since we haven't built this library before, we'll first see an error message indicating that the control file failed to load, then the port will automatically begin building (and install when completed).
```
PS D:\src\vcpkg> .\vcpkg install cpprestsdk
-- CURRENT_INSTALLED_DIR=D:/src/vcpkg/installed/x86-windows
-- DOWNLOADS=D:/src/vcpkg/downloads
-- CURRENT_PACKAGES_DIR=D:/src/vcpkg/packages/cpprestsdk_x86-windows
-- CURRENT_BUILDTREES_DIR=D:/src/vcpkg/buildtrees/cpprestsdk
-- CURRENT_PORT_DIR=D:/src/vcpkg/ports/cpprestsdk/.
-- Cloning done
-- Adding worktree and patching done
-- Configuring x86-windows-rel
-- Configuring x86-windows-rel done
-- Configuring x86-windows-dbg
-- Configuring x86-windows-dbg done
-- Build x86-windows-rel
-- Build x86-windows-rel done
-- Build x86-windows-dbg
-- Build x86-windows-dbg done
-- Package x86-windows-rel
-- Package x86-windows-rel done
-- Package x86-windows-dbg
-- Package x86-windows-dbg done
Package cpprestsdk:x86-windows is installed
```
In addition to installing, `vcpkg` caches a pristine copy of the built library inside the `packages\` directory (in this case, `packages\cpprestsdk_x86-windows`). This allows you to quickly uninstall and reinstall the library in the future using the `remove` and `install` commands.

We can check that cpprestsdk was successfully installed for x86 windows desktop by running the `list` command.
```
PS D:\src\vcpkg> .\vcpkg list
cpprestsdk:x86-windows      2.8              A modern C++11 library to connect with web servic...
```

To install for other architectures and platforms such as Universal Windows Platform or x64 Desktop, you can suffix the package name with `:<target>`.
```
PS D:\src\vcpkg> .\vcpkg install cpprestsdk:x86-uwp zlib:x64-windows
```

See `vcpkg help arch` for all supported targets.

<a name="example-1-2"></a>
### Step 2: Use
<a name="example-1-2-a"></a>
#### Option A: VS Project (User-wide integration)

The recommended and most productive way to use vcpkg is via user-wide integration, making the system available for all projects you build. The user-wide integration will require administrator access the first time it is used on a given machine. After the first use, administrator access is no longer required and the integration is on a per-user basis.
```
PS D:\src\vcpkg> .\vcpkg integrate install
Applied user-wide integration for this vcpkg root.

All C++ projects can now #include any installed libraries.
Linking will be handled automatically.
Installing new libraries will make them instantly available.
```
*Note: You will need to restart Visual Studio or perform a Build to update intellisense with the changes.* 

To remove the integration for your user, you can use `vcpkg integrate remove`.

<a name="example-1-2-b"></a>
#### Option B: CMake (Toolchain File)

The best way to use installed libraries with cmake is via the toolchain file `scripts\buildsystems\vcpkg.cmake`. To use this file, you simply need to add it onto your CMake command line as `-DCMAKE_TOOLCHAIN_FILE=D:\src\vcpkg\scripts\buildsystems\vcpkg.cmake`.

Let's first make a simple CMake project with a main file.
```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.0)
project(test)

find_library(CPPREST_LIBRARY cpprest_2_8)
find_path(CPPREST_INCLUDE_DIR cpprest/version.h)

include_directories(${CPPREST_INCLUDE_DIR})
link_libraries(${CPPREST_LIBRARY})
add_executable(main main.cpp)
```
```cpp
// main.cpp
#include <cpprest/json.h>
#include <stdio.h>

int main()
{
    auto v = web::json::value::parse(U("[1,2,3,4]"));
    printf("Success\n");
    return 0;
}
```

Then, we build our project in the normal CMake way:
```
PS D:\src\cmake-test> mkdir build
PS D:\src\cmake-test> cd build
PS D:\src\cmake-test\build> cmake .. "-DCMAKE_TOOLCHAIN_FILE=D:\src\vcpkg\scripts\buildsystems\vcpkg.cmake"
    // omitted CMake output here //
-- Build files have been written to: D:/src/cmake-test/build
PS D:\src\cmake-test\build> cmake --build .
    // omitted MSBuild output here //
Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:02.38
PS D:\src\cmake-test\build> .\Debug\main.exe
Success
```

<a name="example-1-2-c"></a>
#### Option C: Other buildsystems

Libraries are installed into the `installed\` subfolder, partitioned by architecture (e.g. x86-windows):
* The header files are installed to `installed\x86-windows\include`
* Release `.lib` files are installed to `installed\x86-windows\lib`
* Release `.dll` files are installed to `installed\x86-windows\bin`
* Debug `.lib` files are installed to `installed\x86-windows\debug\lib`
* Debug `.dll` files are installed to `installed\x86-windows\debug\bin`

See your build system specific documentation for how to use prebuilt binaries.

Generally, to run any produced executables you will also need to either copy the needed `dll` files to the same folder as your `exe` or *prepend* the correct `bin` directory to your path.

Example for setting the path for debug mode in powershell:
```
PS D:\src\vcpkg> $env:path = "D:\src\vcpkg\installed\x86-windows\debug\bin;" + $env:path
```
<a name="example-1-2-d"></a>
#### Option D: VS Project (Individual Project integration)

We also provide individual VS project integration through a NuGet package. This will modify the project file, so we do not recommend this approach for open source projects.
```
PS D:\src\vcpkg> .\vcpkg integrate project
Created nupkg: D:\src\vcpkg\scripts\buildsystems\vcpkg.D.src.vcpkg.1.0.0.nupkg

With a project open, go to Tools->NuGet Package Manager->Package Manager Console and paste:
    Install-Package vcpkg.D.src.vcpkg -Source "D:/src/vcpkg/scripts/buildsystems"
```
*Note: The generated NuGet package does not contain the actual libraries. It instead acts like a shortcut (or symlink) to the vcpkg install and will "automatically" update with any changes (install/remove) to the libraries. You do not need to regenerate or update the NuGet package.*

<a name="example-2"></a>
## Example 2: Package a remote project (zlib)

### Bootstrap with `create`
First, locate a globally accessible archive of the library's sources. Zip, gzip, and bzip are all supported. Strongly prefer official sources or mirrors over unofficial mirrors.

*Looking at zlib's website, the URL http://zlib.net/zlib128.zip looks appropriate.*

Second, determine a suitable package name. This should be ASCII, lowercase, and recognizable to someone who knows the library's "human name". If the library is already packaged in another package manager, prefer that name.

*Since zlib is already packaged as zlib, we will use the name zlib2 for this example.*

Finally, if the server's name for the archive is not very descriptive (such as downloading a zipped commit or branch from GitHub), choose a nice archive name of the form `<packagename>-<version>.zip`.

*`zlib128.zip` is a fine name, so no change needed.*

All this information can then be passed into the `create` command, which will download the sources and bootstrap the packaging process inside `ports\<packagename>`.

```
PS D:\src\vcpkg> .\vcpkg create zlib2 http://zlib.net/zlib128.zip zlib128.zip
-- Generated portfile: D:/src/vcpkg/ports/zlib2/portfile.cmake
```

### Create the CONTROL file
In addition to the generated `ports\<package>\portfile.cmake`, We also need a `ports\<package>\CONTROL` file. This file is a simply formatted set of fields describing the package's metadata.

*For zlib2, we'll create the file `ports\zlib2\CONTROL` with the following contents:*
```
Source: zlib2
Version: 1.2.8
Description: A Massively Spiffy Yet Delicately Unobtrusive Compression Library
```

### Tweak the generated portfile
The generated `portfile.cmake` will need some editing to correctly package most libraries in the wild, however we can start by trying out the build.

```
PS D:\src\vcpkg> .\vcpkg build zlib2
-- CURRENT_INSTALLED_DIR=D:/src/vcpkg/installed/x86-windows
-- DOWNLOADS=D:/src/vcpkg/downloads
-- CURRENT_PACKAGES_DIR=D:/src/vcpkg/packages/zlib2_x86-windows
-- CURRENT_BUILDTREES_DIR=D:/src/vcpkg/buildtrees/zlib2
-- CURRENT_PORT_DIR=D:/src/vcpkg/ports/zlib2
-- Using cached D:/src/vcpkg/downloads/zlib128.zip
-- Extracting source D:/src/vcpkg/downloads/zlib128.zip
-- Extracting done
-- Configuring x86-windows-rel
CMake Error at scripts/cmake/vcpkg_execute_required_process.cmake:13 (message):
  Command failed: C:/Program Files
  (x86)/CMake/bin/cmake.exe;D:/src/vcpkg/buildtrees/zlib2/src/zlib128;-G;Ninja;-DCMAKE_VERBOSE_MAKEFILE=ON;-DCMAKE_BUILD_TYPE=Release;-DCMAKE_TOOLCHAIN_FILE=D:/src/vcpkg/triplets/x86-windows.cmake;-DCMAKE_PREFIX_PATH=D:/src/vcpkg/installed/x86-windows;-
DCMAKE_INSTALL_PREFIX=D:/src/vcpkg/packages/zlib2_x86-windows


  Working Directory: D:/src/vcpkg/buildtrees/zlib2/x86-windows-rel

  See logs for more information:

      D:/src/vcpkg/buildtrees/zlib2/config-x86-windows-rel-out.log
      D:/src/vcpkg/buildtrees/zlib2/config-x86-windows-rel-err.log

Call Stack (most recent call first):
  scripts/cmake/vcpkg_configure_cmake.cmake:15 (vcpkg_execute_required_process)
  ports/zlib2/portfile.cmake:8 (vcpkg_configure_cmake)
  scripts/ports.cmake:105 (include)
  scripts/ports.cmake:184 (build)
```

At this point, it is a matter of reading the error messages and log files while steadily improving the quality of the portfile. Zlib required providing a discrete copy of the LICENSE to copy into the package, suppressing the build and installation of executables and headers, and removing the static libraries after they were installed.

### Suggested example portfiles
In the `ports\` directory are many libraries that can be used as examples, including many that are not based on CMake.

- Header only libraries
    - rapidjson
    - range-v3
- MSBuild-based
    - mpg123
    - glew
- Non-CMake, custom buildsystem
    - openssl
    - boost

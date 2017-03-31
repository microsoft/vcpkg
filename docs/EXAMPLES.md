# Vcpkg

## Overview
Vcpkg helps you get C and C++ libraries on Windows.

For short description of available commands, run `.\vcpkg help`.

## Table of Contents
- <a href="#example-1">Example 1: Using Sqlite</a>
  - <a href="#example-1-1">Step 1: Build</a>
  - <a href="#example-1-2">Step 2: Use</a>
    - <a href="#example-1-2-a">Option A: VS Project (User-wide integration)</a>
    - <a href="#example-1-2-b">Option B: CMake (Toolchain file)</a>
    - <a href="#example-1-2-c">Option C: Other buildsystems</a>
    - <a href="#example-1-2-d">Option D: VS Project (Individual Project integration)</a>
- <a href="#example-2">Example 2: Package a remote project (zlib)</a>
- <a href="example-3-patch-libpng.md">Example 3: Patching libpng to work for uwp-x86</a>

<a name="example-1"></a>
## Example 1: Using Sqlite
<a name="example-1-1"></a>
### Step 1: Build

First, we need to know what name [Sqlite](https://sqlite.org) goes by in the ports tree. To do that, we'll run the `search` command and inspect the output:
```
PS D:\src\vcpkg> .\vcpkg search sqlite
libodb-sqlite        2.4.0            Sqlite support for the ODB ORM library
sqlite3              3.15.0           SQLite is a software library that implements a se...

If your library is not listed, please open an issue at:
    https://github.com/Microsoft/vcpkg/issues
```
Looking at the list, we can see that the port is named "sqlite3". You can also run the `search` command without arguments to see the full list of packages.

Installing is then as simple as using the `install` command.
```
PS D:\src\vcpkg> .\vcpkg install sqlite3
-- CURRENT_INSTALLED_DIR=D:/src/vcpkg/installed/x86-windows
-- DOWNLOADS=D:/src/vcpkg/downloads
-- CURRENT_PACKAGES_DIR=D:/src/vcpkg/packages/sqlite3_x86-windows
-- CURRENT_BUILDTREES_DIR=D:/src/vcpkg/buildtrees/sqlite3
-- CURRENT_PORT_DIR=D:/src/vcpkg/ports/sqlite3/.
-- Downloading https://sqlite.org/2016/sqlite-amalgamation-3150000.zip...
-- Downloading https://sqlite.org/2016/sqlite-amalgamation-3150000.zip... OK
-- Testing integrity of downloaded file...
-- Testing integrity of downloaded file... OK
-- Extracting source D:/src/vcpkg/downloads/sqlite-amalgamation-3150000.zip
-- Extracting done
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
-- Performing post-build validation
-- Performing post-build validation done
Package sqlite3:x86-windows is installed
```
In addition to installing, `vcpkg` caches a pristine copy of the built library inside the `packages\` directory -- in this case, `packages\sqlite3_x86-windows`. This allows you to quickly uninstall and reinstall the library in the future using the `remove` and `install` commands.

We can check that sqlite3 was successfully installed for x86 windows desktop by running the `list` command.
```
PS D:\src\vcpkg> .\vcpkg list
sqlite3:x86-windows         3.15.0           SQLite is a software library that implements a se...
```

To install for other architectures and platforms such as Universal Windows Platform or x64 Desktop, you can suffix the package name with `:<target>`.
```
PS D:\src\vcpkg> .\vcpkg install sqlite3:x86-uwp zlib:x64-windows
```

See `.\vcpkg help triplet` for all supported targets.

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

You can now simply use File -> New Project in Visual Studio 2015 or Visual Studio "15" Preview and the library will be automatically available. For Sqlite, you can try out their [C/C++ sample](https://sqlite.org/quickstart.html).

To remove the integration for your user, you can use `.\vcpkg integrate remove`.

<a name="example-1-2-b"></a>
#### Option B: CMake (Toolchain File)

The best way to use installed libraries with cmake is via the toolchain file `scripts\buildsystems\vcpkg.cmake`. To use this file, you simply need to add it onto your CMake command line as `-DCMAKE_TOOLCHAIN_FILE=D:\src\vcpkg\scripts\buildsystems\vcpkg.cmake`.

Let's first make a simple CMake project with a main file.
```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.0)
project(test)

find_package(Sqlite3 REQUIRED)

link_libraries(sqlite3)
add_executable(main main.cpp)
```
```cpp
// main.cpp
#include <sqlite3.h>
#include <stdio.h>

int main()
{
    printf("%s\n", sqlite3_libversion());
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
3.15.0
```

*Note: The correct sqlite3.dll is automatically copied to the output folder when building for x86-windows. You will need to distribute this along with your application.*

Unlike other platforms, we do not automatically add the `include\` directory to your compilation line by default. If you're using a library that does not provide CMake integration, you will need to explicitly search for the files and add them yourself using [`find_path()`][1] and [`find_library()`][2].

```cmake
# To find and use catch
find_path(CATCH_INCLUDE_DIR catch.hpp)
include_directories(${CATCH_INCLUDE_DIR})

# To find and use azure-storage-cpp
find_path(WASTORAGE_INCLUDE_DIR was/blob.h)
find_library(WASTORAGE_LIBRARY wastorage)
include_directories(${WASTORAGE_INCLUDE_DIR})
link_libraries(${WASTORAGE_LIBRARY})

# Note that we recommend using the target-specific directives for a cleaner cmake:
#     target_include_directories(main ${LIBRARY})
#     target_link_libraries(main PRIVATE ${LIBRARY})
```

[1]: https://cmake.org/cmake/help/latest/command/find_path.html
[2]: https://cmake.org/cmake/help/latest/command/find_library.html

<a name="example-1-2-c"></a>
#### Option C: Other buildsystems

Libraries are installed into the `installed\` subfolder, partitioned by architecture (e.g. x86-windows):
* The header files are installed to `installed\x86-windows\include`
* Release `.lib` files are installed to `installed\x86-windows\lib` or `installed\x86-windows\lib\manual-link`
* Release `.dll` files are installed to `installed\x86-windows\bin`
* Debug `.lib` files are installed to `installed\x86-windows\debug\lib` or `installed\x86-windows\debug\lib\manual-link`
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

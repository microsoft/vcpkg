## Installing and Using Packages Example: SQLite

_Note: this old example uses Classic Mode, but most developers will be happier with Manifest Mode. See [Manifest Mode: CMake Example](manifest-mode-cmake.md) for an example of converting to Manifest Mode._

  - [Step 1: Install](#install)
  - [Step 2: Use](#use)
    - [VS/MSBuild Project (User-wide integration)](#msbuild)
    - [CMake (Toolchain file)](#cmake)
    - [Other integration options](../users/buildsystems/integration.md)

---
<a name="install"></a>
## Step 1: Install

First, we need to know what name [SQLite](https://sqlite.org) goes by in the ports tree. To do that, we'll run the `search` command and inspect the output:
```no-highlight
PS D:\src\vcpkg> .\vcpkg search sqlite
libodb-sqlite        2.4.0            Sqlite support for the ODB ORM library
sqlite3              3.32.1           SQLite is a software library that implements a se...

If your library is not listed, please open an issue at:
    https://github.com/Microsoft/vcpkg/issues
```
Looking at the list, we can see that the port is named "sqlite3". You can also run the `search` command without arguments to see the full list of packages.

Installing is then as simple as using the `install` command.
```no-highlight
PS D:\src\vcpkg> .\vcpkg install sqlite3
Computing installation plan...
The following packages will be built and installed:
    sqlite3[core]:x86-windows
Starting package 1/1: sqlite3:x86-windows
Building package sqlite3[core]:x86-windows...
-- Downloading https://sqlite.org/2020/sqlite-amalgamation-3320100.zip...
-- Extracting source C:/src/vcpkg/downloads/sqlite-amalgamation-3320100.zip
-- Applying patch fix-arm-uwp.patch
-- Using source at C:/src/vcpkg/buildtrees/sqlite3/src/3320100-15aeda126a.clean
-- Configuring x86-windows
-- Building x86-windows-dbg
-- Building x86-windows-rel
-- Performing post-build validation
-- Performing post-build validation done
Building package sqlite3[core]:x86-windows... done
Installing package sqlite3[core]:x86-windows...
Installing package sqlite3[core]:x86-windows... done
Elapsed time for package sqlite3:x86-windows: 12 s

Total elapsed time: 12.04 s

The package sqlite3:x86-windows provides CMake targets:

    find_package(unofficial-sqlite3 CONFIG REQUIRED)
    target_link_libraries(main PRIVATE unofficial::sqlite3::sqlite3))

```

We can check that sqlite3 was successfully installed for x86 Windows desktop by running the `list` command.
```no-highlight
PS D:\src\vcpkg> .\vcpkg list
sqlite3:x86-windows         3.32.1           SQLite is a software library that implements a se...
```

To install for other architectures and platforms such as Universal Windows Platform or x64 Desktop, you can suffix the package name with `:<target>`.
```no-highlight
PS D:\src\vcpkg> .\vcpkg install sqlite3:x86-uwp zlib:x64-windows
```

See `.\vcpkg help triplet` for all supported targets.

---
<a name="use"></a>
## Step 2: Use
<a name="msbuild"></a>
#### VS/MSBuild Project (User-wide integration)

The recommended and most productive way to use vcpkg is via user-wide integration, making the system available for all projects you build. The user-wide integration will prompt for administrator access the first time it is used on a given machine, but afterwards is no longer required and the integration is configured on a per-user basis.
```no-highlight
PS D:\src\vcpkg> .\vcpkg integrate install
Applied user-wide integration for this vcpkg root.

All C++ projects can now #include any installed libraries.
Linking will be handled automatically.
Installing new libraries will make them instantly available.
```
*Note: You will need to restart Visual Studio or perform a Build to update intellisense with the changes.* 

You can now simply use File -> New Project in Visual Studio and the library will be automatically available. For SQLite, you can try out their [C/C++ sample](https://sqlite.org/quickstart.html).

To remove the integration for your user, you can use `.\vcpkg integrate remove`.

<a name="cmake"></a>
#### CMake (Toolchain File)

The best way to use installed libraries with cmake is via the toolchain file `scripts\buildsystems\vcpkg.cmake`. To use this file, you simply need to add it onto your CMake command line as:  
`-DCMAKE_TOOLCHAIN_FILE=D:\src\vcpkg\scripts\buildsystems\vcpkg.cmake`.

If you are using CMake through Open Folder with Visual Studio you can define `CMAKE_TOOLCHAIN_FILE` by adding a "variables" section to each of your `CMakeSettings.json` configurations:

```json
{
  "configurations": [{
    "name": "x86-Debug",
    "generator": "Visual Studio 15 2017",
    "configurationType" : "Debug",
    "buildRoot":  "${env.LOCALAPPDATA}\\CMakeBuild\\${workspaceHash}\\build\\${name}",
    "cmakeCommandArgs": "",
    "buildCommandArgs": "-m -v:minimal",
    "variables": [{
      "name": "CMAKE_TOOLCHAIN_FILE",
      "value": "D:\\src\\vcpkg\\scripts\\buildsystems\\vcpkg.cmake"
    }]
  }]
}
```
*Note: It might be necessary to delete the CMake cache folder of each modified configuration, to force a full regeneration. In the `CMake` menu, under `Cache (<configuration name>)` you'll find `Delete Cache Folders`.*

Now let's make a simple CMake project with a main file.
```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.0)
project(test)

find_package(unofficial-sqlite3 CONFIG REQUIRED)

add_executable(main main.cpp)

target_link_libraries(main PRIVATE unofficial::sqlite3::sqlite3)
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
```no-highlight
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

##### Handling libraries without native cmake support

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

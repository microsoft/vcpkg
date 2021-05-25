# Manifest Mode: CMake Example

We would like to add [vcpkg manifest support](../users/manifests.md) to an existing cmake project!
Let's create a simple project that prints the fibonacci sequence up to a certain number,
using some common dependencies.

## Initial Layout

Let's create the following file layout:

```no-highlight
fibo/
  src/
    main.cxx
  CMakeLists.txt
```

And we wish to use [fmt](https://github.com/fmtlib/fmt), [range-v3](https://github.com/ericniebler/range-v3),
and [cxxopts](https://github.com/jarro2783/cxxopts).

Let's write our `CMakeLists.txt` first:

```cmake
cmake_minimum_required(VERSION 3.15)

project(fibo CXX)

find_package(fmt REQUIRED)
find_package(range-v3 REQUIRED)
find_package(cxxopts REQUIRED)

add_executable(fibo src/main.cxx)
target_compile_features(fibo PRIVATE cxx_std_17)

target_link_libraries(fibo
  PRIVATE
    fmt::fmt
    range-v3::range-v3
    cxxopts::cxxopts)
```

And then we should add `main.cxx`:

```cxx
#include <cxxopts.hpp>
#include <fmt/format.h>
#include <range/v3/view.hpp>

namespace view = ranges::views;

int fib(int x) {
  int a = 0, b = 1;

  for (int it : view::repeat(0) | view::take(x)) {
    (void)it;
    int tmp = a;
    a += b;
    b = tmp;
  }

  return a;
}

int main(int argc, char** argv) {
  cxxopts::Options options("fibo", "Print the fibonacci sequence up to a value 'n'");
    options.add_options()
      ("n,value", "The value to print to", cxxopts::value<int>()->default_value("10"));

  auto result = options.parse(argc, argv);
  auto n = result["value"].as<int>();

  for (int x : view::iota(1) | view::take(n)) {
    fmt::print("fib({}) = {}\n", x, fib(x));
  }
}
```

This is a simple project of course, but it should give us a clean project to start with.
Let's try it out!

Let's assume you have `fmt`, `range-v3`, and `cxxopts` installed with vcpkg classic mode;
then, you can just do a simple:

```cmd
D:\src\fibo> cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=D:\src\vcpkg\scripts\buildsystems\vcpkg.cmake
-- Building for: Visual Studio 16 2019
-- Selecting Windows SDK version 10.0.18362.0 to target Windows 10.0.19041.
-- The CXX compiler identification is MSVC 19.27.29111.0
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.27.29110/bin/Hostx64/x64/cl.exe - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Configuring done
-- Generating done
-- Build files have been written to: D:/src/fibo/build
D:\src\fibo> cmake --build build
Microsoft (R) Build Engine version 16.7.0+b89cb5fde for .NET Framework
Copyright (C) Microsoft Corporation. All rights reserved.

  Checking Build System
  Building Custom Rule D:/src/fibo/CMakeLists.txt
  main.cxx
  The contents of <span> are available only with C++20 or later.
  fibo.vcxproj -> D:\src\fibo\build\Debug\fibo.exe
  Building Custom Rule D:/src/fibo/CMakeLists.txt
```

And now we can try out the `fibo` binary!

```cmd
D:\src\fibo> .\build\Debug\fibo.exe -n 7 
fib(1) = 1
fib(2) = 1
fib(3) = 2
fib(4) = 3
fib(5) = 5
fib(6) = 8
fib(7) = 13
```

it works!

## Converting to Manifest Mode

We now wish to use manifest mode, so all of our dependencies are managed for us! Let's write a `vcpkg.json`:

```json
{
  "name": "fibo",
  "version-string": "0.1.0",
  "dependencies": [
    "cxxopts",
    "fmt",
    "range-v3"
  ]
}
```

Let's delete the build directory and rerun the build:

```cmd
D:\src\fibo> rmdir /S /Q build
D:\src\fibo> cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=D:\src\vcpkg\scripts\buildsystems\vcpkg.cmake
-- Running vcpkg install
Detecting compiler hash for triplet x64-windows...
The following packages will be built and installed:
    cxxopts[core]:x64-windows
    fmt[core]:x64-windows
    range-v3[core]:x64-windows
Starting package 1/3: cxxopts:x64-windows
Building package cxxopts[core]:x64-windows...
Using cached binary package: C:\Users\me\AppData\Local\vcpkg/archives\d2\d2d1e5302cdfefef2fd090d8eda84cc0c1fbe6f1.zip
Building package cxxopts[core]:x64-windows... done
Installing package cxxopts[core]:x64-windows...
Installing package cxxopts[core]:x64-windows... done
Elapsed time for package cxxopts:x64-windows: 50.64 ms
Starting package 2/3: fmt:x64-windows
Building package fmt[core]:x64-windows...
Using cached binary package: C:\Users\me\AppData\Local\vcpkg/archives\bf\bf00d5214e912d71414b545b241f54ef87fdf6e5.zip
Building package fmt[core]:x64-windows... done
Installing package fmt[core]:x64-windows...
Installing package fmt[core]:x64-windows... done
Elapsed time for package fmt:x64-windows: 225 ms
Starting package 3/3: range-v3:x64-windows
Building package range-v3[core]:x64-windows...
Using cached binary package: C:\Users\me\AppData\Local\vcpkg/archives\fe\fe2cdedef6953bf954e8ddca471bf3cc8d9b06d7.zip
Building package range-v3[core]:x64-windows... done
Installing package range-v3[core]:x64-windows...
Installing package range-v3[core]:x64-windows... done
Elapsed time for package range-v3:x64-windows: 1.466 s

Total elapsed time: 1.742 s

-- Running vcpkg install - done
-- Selecting Windows SDK version 10.0.18362.0 to target Windows 10.0.19041.
-- The CXX compiler identification is MSVC 19.27.29111.0
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/VC/Tools/MSVC/14.27.29110/bin/Hostx64/x64/cl.exe - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Configuring done
-- Generating done
-- Build files have been written to: D:/src/fibo/build
D:\src\fibo> cmake --build build
Microsoft (R) Build Engine version 16.7.0+b89cb5fde for .NET Framework
Copyright (C) Microsoft Corporation. All rights reserved.

  Checking Build System
  Building Custom Rule D:/src/fibo/CMakeLists.txt
  main.cxx
  The contents of <span> are available only with C++20 or later.
  fibo.vcxproj -> D:\src\fibo\build\Debug\fibo.exe
  Building Custom Rule D:/src/fibo/CMakeLists.txt
```

You can see that with just a _single file_, we've changed over to manifests without _any_ trouble.
The build system doesn't change _at all_! We just add a `vcpkg.json` file, delete the build directory,
and reconfigure. And we're done!

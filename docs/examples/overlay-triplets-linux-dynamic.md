## Overlay Triplets Example: Build dynamic libraries on Linux

Using **vcpkg** you can build libraries for the following triplets:

<div>
    <ul style="columns: 3;">
        <li> arm-uwp</li>
        <li> arm-windows</li>
        <li> arm64-uwp</li>
        <li> arm64-windows</li>
        <li> x86-uwp</li>
        <li> x86-windows</li>
        <li> x86-windows-static</li>
        <li> x64-uwp</li>
        <li> x64-linux</li>
        <li> x64-osx</li>
        <li> x64-windows</li>
        <li> x64-windows-static</li>
    </ul>
</div>



An important note is that by design **vcpkg** builds only static libraries for Linux and Mac OS.
However, this doesn't mean that you cannot use **vcpkg** to build your dynamic libraries on these platforms.

This document will guide you through creating your own custom triplets to build dynamic libraries using **vcpkg**.

#### Step 1: Create a folder to contain your custom triplets

```
~/vcpkg$ mkdir ../custom-triplets
```

#### Step 2: Create the custom triplet files

To save time, copy the existing `x64-linux.cmake` triplet file.

```
~/vcpkg$ cp ./triplets/x64-linux.cmake ../custom-triplets/x64-linux-dynamic.cmake
```

And modify `custom-triplets/x64-linux-dynamic.cmake` to match the contents below:
```
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

set(VCPKG_CMAKE_SYSTEM_NAME Linux)
```

#### Step 3: Use `--overlay-triplets` to build dynamic libraries

Use the `--overlay-triplets` option to use the triplets in the `custom-triplets` directory. 

```
./vcpkg install rapidjson:x64-linux-dynamic --overlay-triplets=../custom-triplets
The following packages will be built and installed:
    sqlite3[core]:x64-linux
Starting package 1/1: sqlite3:x64-linux-dynamic
Building package sqlite3[core]:x64-linux-dynamic...
-- Loading triplet configuration from: /home/custom-triplets/x64-linux-dynamic.cmake
-- Downloading https://sqlite.org/2019/sqlite-amalgamation-3280000.zip...
-- Extracting source /home/victor/git/vcpkg/downloads/sqlite-amalgamation-3280000.zip
-- Applying patch fix-arm-uwp.patch
-- Using source at /home/victor/git/vcpkg/buildtrees/sqlite3/src/3280000-6a3ff7ce92
-- Configuring x64-linux-dynamic-dbg
-- Configuring x64-linux-dynamic-rel
-- Building x64-linux-dynamic-dbg
-- Building x64-linux-dynamic-rel
-- Performing post-build validation
-- Performing post-build validation done
Building package sqlite3[core]:x64-linux-dynamic... done
Installing package sqlite3[core]:x64-linux-dynamic...
Installing package sqlite3[core]:x64-linux-dynamic... done
Elapsed time for package sqlite3:x64-linux-dynamic: 44.82 s

Total elapsed time: 44.82 s

The package sqlite3:x64-linux-dynamic provides CMake targets:

    find_package(sqlite3 CONFIG REQUIRED)
    target_link_libraries(main PRIVATE sqlite3)
```

Overlay triplets will add your custom triplet files when using `vcpkg install`, `vcpkg update`, `vcpkg upgrade`, and `vcpkg remove`.

When using `--overlay-triplets` a message like this one will appear when using an overlay triplet: 

```
-- Loading triplet configuration from: /home/custom-triplets/x64-linux-dynamic.cmake
```

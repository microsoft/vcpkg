# Overlay triplets example: build dynamic libraries on Linux

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



By design **vcpkg** builds only static libraries for Linux and Mac OS.
However, this doesn't mean that you cannot use **vcpkg** to build your dynamic libraries on these platforms.

This document will guide you through creating your own custom triplets to build dynamic libraries on Linux using **vcpkg**.

### Step 1: Create a folder to contain your custom triplets

```
~/vcpkg$ mkdir ../custom-triplets
```

### Step 2: Create the custom triplet files

To save time, copy the existing `x64-linux.cmake` triplet file.

```
~/vcpkg$ cp ./triplets/x64-linux.cmake ../custom-triplets/x64-linux-dynamic.cmake
```

And modify `custom-triplets/x64-linux-dynamic.cmake` to match the contents below:
```
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
# Change VCPKG_LIBRARY_LINKAGE from static to dynamic
set(VCPKG_LIBRARY_LINKAGE dynamic)

set(VCPKG_CMAKE_SYSTEM_NAME Linux)
```

### Step 3: Use `--overlay-triplets` to build dynamic libraries

Use the `--overlay-triplets` option to include the triplets in the `custom-triplets` directory. 

```
./vcpkg install sqlite3:x64-linux-dynamic --overlay-triplets=../custom-triplets
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

When using the `--overlay-triplets` option, a message like the following lets you know that a custom triplet is being used: 

```
-- Loading triplet configuration from: /home/custom-triplets/x64-linux-dynamic.cmake
```

## Overriding default triplets

As you may have noticed, the default triplets for Windows (`x86-windows` and `x64-windows`) install dynamic libraries, while a suffix (`-static`) is needed for static libraries. This is inconsistent with Linux and Mac OS where only static libraries are built.

Using `--overlay-ports` it is possible to override the default triplets to accomplish the same behavior on Linux:

* `x64-linux`: Builds dynamic libraries,
* `x64-linux-static`: Builds static libraries.

### Step 1: Create the overriden triplet

Using the custom triplet created in the previous example, rename `custom-triplets/x64-linux-dynamic.cmake` to `custom-triplets/x64-linux.cmake`.

```
~/vcpkg$ mv ../custom-triplets/x64-linux-dynamic.cmake ../custom-triplets/x64-linux.cmake
```

### Step 2: Copy and rename the default triplet

Then, copy the default `x64-linux` triplet (which builds static libraries) in your `/custom-triplets` folder and rename it to `x64-linux-static.cmake`.

```
~/vcpkg$ cp ./triplets/x64-linux.cmake ../custom-triplets/x64-linux-static.cmake
```

### Step 3: Use `--overlay-ports` to override default triplets

Use the `--overlay-triplets` option to include the triplets in the `custom-triplets` directory.

```
./vcpkg install sqlite3:x64-linux --overlay-triplets=../custom-triplets
The following packages will be built and installed:
    sqlite3[core]:x64-linux
Starting package 1/1: sqlite3:x64-linux
Building package sqlite3[core]:x64-linux...
-- Loading triplet configuration from: /home/custom-triplets/x64-linux.cmake
-- Downloading https://sqlite.org/2019/sqlite-amalgamation-3280000.zip...
-- Extracting source /home/victor/git/vcpkg/downloads/sqlite-amalgamation-3280000.zip
-- Applying patch fix-arm-uwp.patch
-- Using source at /home/victor/git/vcpkg/buildtrees/sqlite3/src/3280000-6a3ff7ce92
-- Configuring x64-linux-dbg
-- Configuring x64-linux-rel
-- Building x64-linux-dbg
-- Building x64-linux-rel
-- Performing post-build validation
-- Performing post-build validation done
Building package sqlite3[core]:x64-linux... done
Installing package sqlite3[core]:x64-linux...
Installing package sqlite3[core]:x64-linux... done
Elapsed time for package sqlite3:x64-linux: 44.82 s

Total elapsed time: 44.82 s

The package sqlite3:x64-linux provides CMake targets:

    find_package(sqlite3 CONFIG REQUIRED)
    target_link_libraries(main PRIVATE sqlite3)
```

Note that the default triplet is masked by your custom triplet:

```
-- Loading triplet configuration from: /home/custom-triplets/x64-linux.cmake
```

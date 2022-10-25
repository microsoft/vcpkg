## Patching Example: Patching libpng to work for x64-uwp

### Initial error logs
First, try building:

```no-highlight
PS D:\src\vcpkg> vcpkg install libpng:x64-uwp --editable
Computing installation plan...
The following packages will be built and installed:
    libpng[core]:x64-uwp
Starting package 1/1: libpng:x64-uwp
Building package libpng[core]:x64-uwp...
-- Using cached D:/src/vcpkg/downloads/glennrp-libpng-v1.6.37.tar.gz
-- Extracting source D:/src/vcpkg/downloads/glennrp-libpng-v1.6.37.tar.gz
-- Using source at D:/src/vcpkg/buildtrees/libpng/src/v1.6.37-c993153cdf
-- Configuring x64-uwp
-- Building x64-uwp-rel
CMake Error at scripts/cmake/execute_required_process.cmake:14 (message):
  Command failed: C:/Program Files/CMake/bin/cmake.exe;--build;.;--config;Release

  Working Directory: D:/src/vcpkg/buildtrees/libpng/x64-uwp-rel

  See logs for more information:

      D:\src\vcpkg\buildtrees\libpng\build-x64-uwp-rel-out.log
      D:\src\vcpkg\buildtrees\libpng\build-x64-uwp-rel-err.log

Call Stack (most recent call first):
  scripts/cmake/vcpkg_build_cmake.cmake:3 (execute_required_process)
  ports/libpng/portfile.cmake:22 (vcpkg_build_cmake)
  scripts/ports.cmake:84 (include)


Error: build command failed
```

Next, looking at the above logs (build-xxx-out.log and build-xxx-err.log).

```no-highlight
// build-x64-uwp-rel-out.log
...
"D:\src\vcpkg\buildtrees\libpng\x64-uwp-rel\ALL_BUILD.vcxproj" (default target) (1) ->
"D:\src\vcpkg\buildtrees\libpng\x64-uwp-rel\png.vcxproj" (default target) (3) ->
(ClCompile target) -> 
  D:\src\vcpkg\buildtrees\libpng\src\v1.6.37-c993153cdf\pngerror.c(775): warning C4013: 'ExitProcess' undefined; assuming extern returning int [D:\src\vcpkg\buildtrees\libpng\x64-uwp-rel\png.vcxproj]


"D:\src\vcpkg\buildtrees\libpng\x64-uwp-rel\ALL_BUILD.vcxproj" (default target) (1) ->
"D:\src\vcpkg\buildtrees\libpng\x64-uwp-rel\png.vcxproj" (default target) (3) ->
(Link target) -> 
  pngerror.obj : error LNK2019: unresolved external symbol _ExitProcess referenced in function _png_longjmp [D:\src\vcpkg\buildtrees\libpng\x64-uwp-rel\png.vcxproj]
  D:\src\vcpkg\buildtrees\libpng\x64-uwp-rel\Release\libpng16.dll : fatal error LNK1120: 1 unresolved externals [D:\src\vcpkg\buildtrees\libpng\x64-uwp-rel\png.vcxproj]

    1 Warning(s)
    2 Error(s)

Time Elapsed 00:00:04.19
```

### Identify the problematic code

Taking a look at [MSDN](https://msdn.microsoft.com/en-us/library/windows/desktop/ms682658(v=vs.85).aspx) shows that `ExitProcess` is only available for desktop apps. Additionally, it's useful to see the surrounding context:

```c
/* buildtrees\libpng\src\v1.6.37-c993153cdf\pngerror.c:769 */
    /* If control reaches this point, png_longjmp() must not return. The only
    * choice is to terminate the whole process (or maybe the thread); to do
    * this the ANSI-C abort() function is used unless a different method is
    * implemented by overriding the default configuration setting for
    * PNG_ABORT().
    */
    PNG_ABORT();
```

A recursive search for `PNG_ABORT` reveals the definition:
```no-highlight
PS D:\src\vcpkg\buildtrees\libpng\src\v1.6.37-c993153cdf> findstr /snipl "PNG_ABORT" *
CHANGES:701:  Added PNG_SETJMP_SUPPORTED, PNG_SETJMP_NOT_SUPPORTED, and PNG_ABORT() macros
libpng-manual.txt:432:errors will result in a call to PNG_ABORT() which defaults to abort().
libpng-manual.txt:434:You can #define PNG_ABORT() to a function that does something
libpng-manual.txt:2753:errors will result in a call to PNG_ABORT() which defaults to abort().
libpng-manual.txt:2755:You can #define PNG_ABORT() to a function that does something
libpng-manual.txt:4226:PNG_NO_SETJMP, in which case it is handled via PNG_ABORT()),
libpng.3:942:errors will result in a call to PNG_ABORT() which defaults to abort().
libpng.3:944:You can #define PNG_ABORT() to a function that does something
libpng.3:3263:errors will result in a call to PNG_ABORT() which defaults to abort().
libpng.3:3265:You can #define PNG_ABORT() to a function that does something
libpng.3:4736:PNG_NO_SETJMP, in which case it is handled via PNG_ABORT()),
png.h:994: * will use it; otherwise it will call PNG_ABORT().  This function was
pngerror.c:773:    * PNG_ABORT().
pngerror.c:775:   PNG_ABORT();
pngpriv.h:459:#ifndef PNG_ABORT
pngpriv.h:461:#    define PNG_ABORT() ExitProcess(0)
pngpriv.h:463:#    define PNG_ABORT() abort()
```

This already gives us some great clues, but the full definition tells the complete story.

```c
/* buildtrees\libpng\src\v1.6.37-c993153cdf\pngpriv.h:459 */
#ifndef PNG_ABORT
#  ifdef _WINDOWS_
#    define PNG_ABORT() ExitProcess(0)
#  else
#    define PNG_ABORT() abort()
#  endif
#endif
```

`abort()` is a standard CRT call and certainly available in UWP, so we just need to convince libpng to be more platform agnostic. The easiest and most reliable way to achieve this is to patch the code; while in this particular case we could pass in a compiler flag to override `PNG_ABORT` because this is a private header, in general it is more reliable to avoid adding more required compiler switches when possible (especially when it isn't already exposed as a CMake option).

### Patching the code to improve compatibility

We recommend using git to create the patch file, since you'll already have it installed.
```no-highlight
PS D:\src\vcpkg\buildtrees\libpng\src\v1.6.37-c993153cdf> git init .
Initialized empty Git repository in D:/src/vcpkg/buildtrees/libpng/src/v1.6.37-c993153cdf/.git/

PS D:\src\vcpkg\buildtrees\libpng\src\v1.6.37-c993153cdf> git add .
warning: LF will be replaced by CRLF in ANNOUNCE.
The file will have its original line endings in your working directory.
...

PS D:\src\vcpkg\buildtrees\libpng\src\v1.6.37-c993153cdf> git commit -m "temp"
[master (root-commit) 68f253f] temp
 422 files changed, 167717 insertions(+)
...
```

Now we can modify `pngpriv.h` to use `abort()` everywhere.
```c
/* buildtrees\libpng\src\v1.6.37-c993153cdf\pngpriv.h:459 */
#ifndef PNG_ABORT
#  define PNG_ABORT() abort()
#endif
```

The output of `git diff` is already in patch format, so we just need to save the patch into the `ports/libpng` directory.
```no-highlight
PS buildtrees\libpng\src\v1.6.37-c993153cdf> git diff --ignore-space-at-eol | out-file -enc ascii ..\..\..\..\ports\libpng\use-abort-on-all-platforms.patch
```

Finally, we need to apply the patch after extracting the source.
```cmake
# ports\libpng\portfile.cmake
...
vcpkg_extract_source_archive_ex(
  OUT_SOURCE_PATH SOURCE_PATH
  ARCHIVE ${ARCHIVE}
  PATCHES 
    "use-abort-on-all-platforms.patch"
)

vcpkg_cmake_configure(
...
```

### Verification

To be completely sure this works from scratch, we need to remove the package and rebuild it:

```no-highlight
PS D:\src\vcpkg> vcpkg remove libpng:x64-uwp
Package libpng:x64-uwp was successfully removed
```

Now we try a fresh, from scratch install.

```no-highlight
PS D:\src\vcpkg> vcpkg install libpng:x64-uwp
Computing installation plan...
The following packages will be built and installed:
    libpng[core]:x64-uwp
Starting package 1/1: libpng:x64-uwp
Building package libpng[core]:x64-uwp...
Could not locate cached archive: C:\Users\me\AppData\Local\vcpkg/archives\f4\f44b54f818f78b9a4ccd34b3666f566f94286850.zip
-- Using cached D:/src/vcpkg/downloads/glennrp-libpng-v1.6.37.tar.gz
-- Extracting source D:/src/vcpkg/downloads/glennrp-libpng-v1.6.37.tar.gz
-- Applying patch use_abort.patch
-- Applying patch cmake.patch
-- Applying patch pkgconfig.patch
-- Applying patch pkgconfig.2.patch
-- Using source at D:/src/vcpkg/buildtrees/libpng/src/v1.6.37-10db9f58e4.clean
-- Configuring x64-uwp
-- Building x64-uwp-dbg
-- Building x64-uwp-rel
-- Fixing pkgconfig file: D:/src/vcpkg/packages/libpng_x64-uwp/lib/pkgconfig/libpng.pc
-- Fixing pkgconfig file: D:/src/vcpkg/packages/libpng_x64-uwp/lib/pkgconfig/libpng16.pc
-- Fixing pkgconfig file: D:/src/vcpkg/packages/libpng_x64-uwp/debug/lib/pkgconfig/libpng.pc
-- Fixing pkgconfig file: D:/src/vcpkg/packages/libpng_x64-uwp/debug/lib/pkgconfig/libpng16.pc
-- Installing: D:/src/vcpkg/packages/libpng_x64-uwp/share/libpng/copyright
-- Performing post-build validation
-- Performing post-build validation done
Stored binary cache: C:\Users\me\AppData\Local\vcpkg/archives\f4\f44b54f818f78b9a4ccd34b3666f566f94286850.zip
Building package libpng[core]:x64-uwp... done
Installing package libpng[core]:x64-uwp...
Installing package libpng[core]:x64-uwp... done
Elapsed time for package libpng:x64-uwp: 11.94 s

Total elapsed time: 11.95 s

The package libpng:x64-uwp provides CMake targets:

    find_package(libpng CONFIG REQUIRED)
    target_link_libraries(main PRIVATE png)
```

Finally, to fully commit and publish the changes, we need to bump the port version in `vcpkg.json`,
and add the patch file to source control, then make a Pull Request!

```json
{
  "name": "libpng",
  "version": "1.6.37",
  "port-version": 1,
  "dependencies": [
    "zlib"
  ]
}
```

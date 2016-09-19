Fixing libpng:x86-uwp
=====================

First, try building:

```
PS D:\src\cpp-packages> vcpkg install libpng:x86-uwp
-- SYSROOT=D:/src/cpp-packages/sysroot/x86-uwp
-- DISTDIR=D:/src/cpp-packages/distdir
-- CURRENT_SOFTWARE_DIR=D:/src/cpp-packages/software/libpng_x86-uwp
-- CURRENT_WORKSRC_DIR=D:/src/cpp-packages/worksrc/libpng
-- CURRENT_PORT_DIR=D:/src/cpp-packages/ports/libpng/.
-- Using cached D:/src/cpp-packages/distdir/libpng-1.6.24.tar.xz
-- Extracting done
-- Configuring x86-uwp-rel
-- Configuring x86-uwp-rel done
-- Configuring x86-uwp-dbg
-- Configuring x86-uwp-dbg done
-- Build x86-uwp-rel
CMake Error at scripts/cmake/execute_required_process.cmake:14 (message):
  Command failed: C:/Program
  Files/CMake/bin/cmake.exe;--build;.;--config;Release

  Working Directory: D:/src/cpp-packages/worksrc/libpng/x86-uwp-rel

  See logs for more information:

      D:\src\cpp-packages\worksrc\libpng\build-x86-uwp-rel-out.log
      D:\src\cpp-packages\worksrc\libpng\build-x86-uwp-rel-err.log

Call Stack (most recent call first):
  scripts/cmake/build_standard_cmake.cmake:3 (execute_required_process)
  ports/libpng/portfile.cmake:22 (build_standard_cmake)
  scripts/ports.cmake:84 (include)


Error: build command failed
```

Next, looking at the above logs (build-...-out.log and build-...-err.log).

```
// build-x86-uwp-rel-out.log
...
"D:\src\cpp-packages\worksrc\libpng\x86-uwp-rel\ALL_BUILD.vcxproj" (default target) (1) ->
"D:\src\cpp-packages\worksrc\libpng\x86-uwp-rel\png.vcxproj" (default target) (3) ->
(ClCompile target) -> 
  D:\src\cpp-packages\worksrc\libpng\src\libpng-1.6.24\pngerror.c(775): warning C4013: 'ExitProcess' undefined; assuming extern returning int [D:\src\cpp-packages\worksrc\libpng\x86-uwp-rel\png.vcxproj]


"D:\src\cpp-packages\worksrc\libpng\x86-uwp-rel\ALL_BUILD.vcxproj" (default target) (1) ->
"D:\src\cpp-packages\worksrc\libpng\x86-uwp-rel\png.vcxproj" (default target) (3) ->
(Link target) -> 
  pngerror.obj : error LNK2019: unresolved external symbol _ExitProcess referenced in function _png_longjmp [D:\src\cpp-packages\worksrc\libpng\x86-uwp-rel\png.vcxproj]
  D:\src\cpp-packages\worksrc\libpng\x86-uwp-rel\Release\libpng16.dll : fatal error LNK1120: 1 unresolved externals [D:\src\cpp-packages\worksrc\libpng\x86-uwp-rel\png.vcxproj]

    1 Warning(s)
    2 Error(s)

Time Elapsed 00:00:04.19
```
Taking a look at [MSDN](https://msdn.microsoft.com/en-us/library/windows/desktop/ms682658(v=vs.85).aspx) shows that `ExitProcess` is only available for desktop apps. Additionally, it's useful to see the surrounding context:

```c
/* worksrc\libpng\src\libpng-1.6.24\pngerror.c:769 */
    /* If control reaches this point, png_longjmp() must not return. The only
    * choice is to terminate the whole process (or maybe the thread); to do
    * this the ANSI-C abort() function is used unless a different method is
    * implemented by overriding the default configuration setting for
    * PNG_ABORT().
    */
    PNG_ABORT();
```

A recursive search for `PNG_ABORT` reveals the definition:
```
PS D:\src\cpp-packages\worksrc\libpng\src\libpng-1.6.24> findstr /snipl "PNG_ABORT" *
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
/* worksrc\libpng\src\libpng-1.6.24\pngpriv.h:459 */
#ifndef PNG_ABORT
#  ifdef _WINDOWS_
#    define PNG_ABORT() ExitProcess(0)
#  else
#    define PNG_ABORT() abort()
#  endif
#endif
```

`abort()` is a standard CRT call and certainly available in UWP, so we just need to convince libpng to be more platform agnostic. The easiest and most reliable way to achive is to patch the code; while in this particular case we could pass in a compiler flag to override `PNG_ABORT` because this is a private header, in general it is more reliable to avoid adding more required compiler switches when possible (especially when it isn't already exposed as a CMake option).

I recommend using git to create the patch file, since you'll already have it installed.
```
PS D:\src\cpp-packages\worksrc\libpng\src\libpng-1.6.24> git init .
Initialized empty Git repository in D:/src/cpp-packages/worksrc/libpng/src/libpng-1.6.24/.git/

PS D:\src\cpp-packages\worksrc\libpng\src\libpng-1.6.24> git add .
warning: LF will be replaced by CRLF in ANNOUNCE.
The file will have its original line endings in your working directory.
...

PS D:\src\cpp-packages\worksrc\libpng\src\libpng-1.6.24> git commit -m "temp"
[master (root-commit) 68f253f] temp
 422 files changed, 167717 insertions(+)
...
```

Now we can modify `pngpriv.h` to use `abort()` everywhere.
```c
/* worksrc\libpng\src\libpng-1.6.24\pngpriv.h:459 */
#ifndef PNG_ABORT
#  define PNG_ABORT() abort()
#endif
```

The output of `git diff` is already in patch format, so we just need to save the patch into the `ports/libpng` directory.
```
PS worksrc\libpng\src\libpng-1.6.24> git diff | out-file -enc ascii ..\..\..\..\ports\libpng\use-abort-on-all-platforms.patch
```

Finally, we need to apply the patch after extracting the source.
```cmake
# ports\libpng\portfile.cmake
...
extract_source_archive(${ARCHIVE})

find_program(GIT git)
execute_required_process(
    COMMAND ${GIT} init
    WORKING_DIRECTORY ${CURRENT_WORKSRC_DIR}/src/libpng-1.6.24
    LOGNAME git-init
)
execute_process(
    COMMAND ${GIT} apply "${CMAKE_CURRENT_LIST_DIR}/use-abort-on-all-platforms.patch" --ignore-whitespace --whitespace=nowarn
    WORKING_DIRECTORY ${CURRENT_WORKSRC_DIR}/src/libpng-1.6.24
)

configure_standard_cmake(
...
```

To be completely sure this works from the top, we need to clear out all the caches.

```
PS D:\src\cpp-packages> vcpkg remove libpng:x86-uwp
Package libpng:x86-uwp was successfully removed
PS D:\src\cpp-packages> vcpkg purge libpng:x86-uwp
Cleaned up D:\src\cpp-packages\software\libpng_x86-uwp
PS D:\src\cpp-packages> vcpkg clean libpng
Cleaned up D:\src\cpp-packages\worksrc\libpng
```

Now we try a fresh, from scratch install.
```
PS D:\src\cpp-packages> vcpkg install libpng:x86-uwp
-- SYSROOT=D:/src/cpp-packages/sysroot/x86-uwp
-- DISTDIR=D:/src/cpp-packages/distdir
-- CURRENT_SOFTWARE_DIR=D:/src/cpp-packages/software/libpng_x86-uwp
-- CURRENT_WORKSRC_DIR=D:/src/cpp-packages/worksrc/libpng
-- CURRENT_PORT_DIR=D:/src/cpp-packages/ports/libpng/.
-- Using cached D:/src/cpp-packages/distdir/libpng-1.6.24.tar.xz
-- Extracting source D:/src/cpp-packages/distdir/libpng-1.6.24.tar.xz
-- Extracting done
-- Configuring x86-uwp-rel
-- Configuring x86-uwp-rel done
-- Configuring x86-uwp-dbg
-- Configuring x86-uwp-dbg done
-- Build x86-uwp-rel
-- Build x86-uwp-rel done
-- Build x86-uwp-dbg
-- Build x86-uwp-dbg done
-- Package x86-uwp-rel
-- Package x86-uwp-rel done
-- Package x86-uwp-dbg
-- Package x86-uwp-dbg done
Package libpng:x86-uwp is installed
```

Finally, to fully commit and publish the changes, we need to bump the internal release number and add the patch file to source control.

```
# ports\libpng\CONTROL
Source: libpng
Version: 1.6.24-1
Build-Depends: zlib
```

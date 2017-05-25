## Example 2: Packaging zlib

### Bootstrap with `create`
First, locate a globally accessible archive of the library's sources. Zip, gzip, and bzip are all supported. Strongly prefer official sources or mirrors over unofficial mirrors.

*Looking at zlib's website, the URL http://zlib.net/zlib128.zip looks appropriate.*

Second, determine a suitable package name. This should be ASCII, lowercase, and recognizable to someone who knows the library's "human name". If the library is already packaged in another package manager, prefer that name.

*Since zlib is already packaged as zlib, we will use the name zlib2 for this example.*

Finally, if the server's name for the archive is not very descriptive (such as downloading a zipped commit or branch from GitHub), choose a nice archive name of the form `<packagename>-<version>.zip`.

*`zlib128.zip` is a fine name, so no change needed.*

All this information can then be passed into the `create` command, which will download the sources and bootstrap the packaging process inside `ports\<packagename>`.

```no-highlight
PS D:\src\vcpkg> .\vcpkg create zlib2 http://zlib.net/zlib128.zip zlib128.zip
-- Generated portfile: D:/src/vcpkg/ports/zlib2/portfile.cmake
```

### Create the CONTROL file
In addition to the generated `ports\<package>\portfile.cmake`, we also need a `ports\<package>\CONTROL` file. This file is a simply formatted set of fields describing the package's metadata.

*For zlib2, we'll create the file `ports\zlib2\CONTROL` with the following contents:*
```no-highlight
Source: zlib2
Version: 1.2.8
Description: A Massively Spiffy Yet Delicately Unobtrusive Compression Library
```

### Tweak the generated portfile
The generated `portfile.cmake` will need some editing to correctly package most libraries in the wild, however we can start by trying out the build.

```no-highlight
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

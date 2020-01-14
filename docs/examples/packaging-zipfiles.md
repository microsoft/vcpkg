## Packaging Zipfiles Example: zlib

### Bootstrap with `create`
First, locate a globally accessible archive of the library's sources. Zip, gzip, and bzip are all supported. Strongly prefer official sources or mirrors over unofficial mirrors.

*Looking at zlib's website, the URL http://zlib.net/zlib1211.zip looks appropriate.*

Second, determine a suitable package name. This should be ASCII, lowercase, and recognizable to someone who knows the library's "human name". If the library is already packaged in another package manager, prefer that name.

*Since zlib is already packaged as zlib, we will use the name zlib2 for this example.*

Finally, if the server's name for the archive is not very descriptive (such as downloading a zipped commit or branch from GitHub), choose a nice archive name of the form `<packagename>-<version>.zip`.

*`zlib1211.zip` is a fine name, so no change needed.*

All this information can then be passed into the `create` command, which will download the sources and bootstrap the packaging process inside `ports\<packagename>`.

```no-highlight
PS D:\src\vcpkg> .\vcpkg create zlib2 http://zlib.net/zlib-1.2.11.tar.gz zlib-1.2.11.zip
-- Generated portfile: D:/src/vcpkg/ports/zlib2/portfile.cmake
```

### Create the CONTROL file
In addition to the generated `ports\<package>\portfile.cmake`, we also need a `ports\<package>\CONTROL` file. This file is a simple set of fields describing the package's metadata.

*For zlib2, we'll create the file `ports\zlib2\CONTROL` with the following contents:*
```no-highlight
Source: zlib2
Version: 1.2.11
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
-- CURRENT_PORT_DIR=D:/src/vcpkg/ports/zlib2/.
-- Using cached D:/src/vcpkg/downloads/zlib-1.2.11.tar.gz
-- Testing integrity of cached file...
-- Testing integrity of cached file... OK
-- Extracting source D:/src/vcpkg/downloads/zlib-1.2.11.tar.gz
-- Extracting done
-- Configuring x86-windows-rel
-- Configuring x86-windows-rel done
-- Configuring x86-windows-dbg
-- Configuring x86-windows-dbg done
-- Build x86-windows-rel
-- Build x86-windows-rel done
-- Build x86-windows-dbg
-- Build x86-windows-dbg done
-- Performing post-build validation
Include files should not be duplicated into the /debug/include directory. If this cannot be disabled in the project cmake, use
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
/debug/share should not exist. Please reorganize any important files, then use
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
The software license must be available at ${CURRENT_PACKAGES_DIR}/share/zlib2/copyright
Found 3 error(s). Please correct the portfile:
    D:\src\vcpkg\ports\zlib2\portfile.cmake
```

At this point, it is a matter of reading the error messages and log files while steadily improving the quality of the portfile. Zlib required providing a discrete copy of the LICENSE to copy into the package, suppressing the build and installation of executables and headers, and removing the static libraries after they were installed.

### Suggested example portfiles
In the `ports\` directory are many libraries that can be used as examples, including many that are not based on CMake.

- Header only libraries
    - rapidjson
    - range-v3
- MSBuild-based
    - cppunit
    - mpg123
- Non-CMake, custom buildsystem
    - openssl
    - ffmpeg

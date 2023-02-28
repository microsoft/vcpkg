## Packaging `.zip` Files Example: zlib

### Bootstrap with `create`
First, locate a globally accessible archive of the library's sources. Zip, gzip, and bzip are all supported. Strongly prefer official sources or mirrors over unofficial mirrors.

*Looking at zlib's website, the URL http://zlib.net/zlib-1.2.12.tar.gz looks appropriate.*

Second, determine a suitable package name. This should be ASCII, lowercase, and recognizable to someone who knows the library's "human name". If the library is already packaged in another package manager, prefer that name.

*Since zlib is already packaged as zlib, we will use the name zlib2 for this example.*

Finally, if the server's name for the archive is not very descriptive (such as downloading a zipped commit or branch from GitHub), choose a nice archive name of the form `<packagename>-<version>.zip`.

*`zlib1212.zip` is a fine name, so no change needed.*

All this information can then be passed into the `create` command, which will download the sources and bootstrap the packaging process inside `ports/<packagename>`.

```no-highlight
PS D:\src\vcpkg> .\vcpkg create zlib2 http://zlib.net/zlib-1.2.12.tar.gz zlib1212.tar.gz
-- Generated portfile: D:/src/vcpkg/ports/zlib2/portfile.cmake
```

### Create the manifest file
In addition to the generated `ports/<package>/portfile.cmake`, we also need a `ports/<package>/vcpkg.json` file. This file is a simple set of fields describing the package's metadata.

*For zlib2, we'll create the file `ports/zlib2/vcpkg.json` with the following contents:*
```json
{
  "name": "zlib2",
  "version-string": "1.2.12",
  "description": "A Massively Spiffy Yet Delicately Unobtrusive Compression Library"
}
```

### Tweak the generated portfile
The generated `portfile.cmake` will need some editing to correctly package most libraries in the wild, however we can start by trying out the build.

```no-highlight
PS D:\src\vcpkg> .\vcpkg install zlib2
Computing installation plan...
The following packages will be built and installed:
    zlib2[core]:x64-uwp
Starting package 1/1: zlib2:x64-uwp
Building package zlib2[core]:x64-uwp...
-- Using cached C:/src/vcpkg/downloads/zlib1212.tar.gz
-- Cleaning sources at C:/src/vcpkg/buildtrees/zlib2/src/1.2.12-deec42f53b.clean. Pass --editable to vcpkg to reuse sources.
-- Extracting source C:/src/vcpkg/downloads/zlib1212.tar.gz
-- Applying patch cmake_dont_build_more_than_needed.patch
-- Using source at C:/src/vcpkg/buildtrees/zlib2/src/1.2.12-deec42f53b.clean
-- Configuring x64-uwp
-- Building x64-uwp-dbg
-- Building x64-uwp-rel
-- Installing: C:/src/vcpkg/packages/zlib2_x64-uwp/share/zlib2/copyright
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
In the `ports/` directory are many libraries that can be used as examples, including many that are not based on CMake.

- Header only libraries
    - rapidjson
    - range-v3
- MSBuild-based
    - mpg123
- Non-CMake, custom buildsystem
    - openssl
    - ffmpeg

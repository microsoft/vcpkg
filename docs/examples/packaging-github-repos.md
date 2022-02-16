## Packaging Github Repos Example: libogg
### Create the manifest file
The manifest file (called `vcpkg.json`) is a json file describing the package's metadata.

For libogg, we'll create the file `ports/libogg/vcpkg.json` with the following content:

```json
{
  "name": "libogg",
  "version-string": "1.3.3",
  "description": "Ogg is a multimedia container format, and the native file and stream format for the Xiph.org multimedia codecs."
}
```

You can format the manifest file to our specifications with `vcpkg format-manifest ports/libogg/vcpkg.json`.

### Create the portfile
`portfile.cmake` describes how to build and install the package. First we download the project from Github with [`vcpkg_from_github`](../maintainers/vcpkg_from_github.md):

```cmake
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/ogg
    REF v1.3.3
    SHA512 0bd6095d647530d4cb1f509eb5e99965a25cc3dd9b8125b93abd6b248255c890cf20710154bdec40568478eb5c4cde724abfb2eff1f3a04e63acef0fbbc9799b
    HEAD_REF master
)
```

The important parts to update are `REPO` for the GitHub repository path, `REF` for a stable tag/commit to use, and `SHA512` with the checksum of the downloaded zipfile (you can get this easily by setting it to `0`, trying to install the package, and copying the checksum).

Finally, we configure the project with CMake, install the package, and copy over the license file:

```cmake
vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libogg" RENAME copyright)
```

Check the documentation for [`vcpkg_cmake_configure`](../maintainers/ports/vcpkg-cmake/vcpkg_cmake_configure.md) and [`vcpkg_cmake_install`](../maintainers/ports/vcpkg-cmake/vcpkg_cmake_install.md) if your package needs additional options. 

Now you can run `vcpkg install libogg` to build and install the package.

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

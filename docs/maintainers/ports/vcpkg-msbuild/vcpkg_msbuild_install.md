# vcpkg_msbuild_install

The latest version of this document lives in the [vcpkg repo](https://github.com/Microsoft/vcpkg/blob/master/docs/maintainers/ports/vcpkg-msbuild/vcpkg_msbuild_install.md).

Build and install a msbuild-based project.

```cmake
vcpkg_msbuild_install(
    SOURCE_PATH <source-path>
    PROJECT_FILE <path-to-solution-or-project>
    [TARGET <target>]
    [INCLUDES_DIRECTORY <path-to-include-dir>]

    [RELEASE_CONFIGURATION <configuration>]
    [DEBUG_CONFIGURATION <configuration>]
    [OPTIONS <option>...]
    [OPTIONS_RELEASE <option>...]
    [OPTIONS_DEBUG <option>...]

    [PLATFORM <msbuild-platform>]
    [PLATFORM_VERSION <platform-version>]
    [PLATFORM_TOOLSET <toolset>]

    [USE_VCPKG_INTEGRATION]
    [DISABLE_PARALLEL]
    [SKIP_CLEAN]
    [ALLOW_ROOT_INCLUDES]
)
```

`vcpkg_msbuild_install()` is the only function one needs when
building an MSBuild project: unlike other build systems,
which have a configure step followed by an install step,
`vcpkg_msbuild_install` is complete in and of itself.
The only required parameters are `SOURCE_PATH` and `PROJECT_FILE`;
`SOURCE_PATH` should be set to `${SOURCE_PATH}` by convention,
while the `PROJECT_FILE` should be a relative path to the project or solution file.

One thing which should be noted is that because MSBuild uses in-source builds,
the source tree will be copied into a temporary location for the build.

`vcpkg_msbuild_install()` will run a build, and then install all of the important bits.
It will auto-detect `.lib` and `.dll` files after the build.
However, this is not possible in general for headers:
for "well-behaved" libraries, i.e., those which have a header structure like:

```
include/
  libname/
    *.h
```

passing `INCLUDES_DIRECTORY include` as an option will Just Work.
However, for libraries where there are top-level headers
(i.e., `include/libname.h`), `ALLOW_ROOT_INCLUDES` will make that work.
For more complex installation requirements,
pass `SKIP_CLEAN` and do manual header installation.
The build directory shall be `"${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-<config>"`,
where `<config>` is one of `rel` or `dbg` for release and debug respectively;
and since msbuild does not support out-of-tree builds, the source will be there as well.

If you do end up passing `SKIP_CLEAN`, _make sure to call_ [`vcpkg_msbuild_clean()`]
after doing your manual installation steps.

`vcpkg_msbuild_install()` defaults to using `Release` and `Debug` for their respective
configurations.

Additionally, it defaults to the following platforms per architecture:
- `x86` - `Win32`
- `x64` - `x64`
- `arm` - `ARM`
- `arm64` - `arm64`
If your project uses different architecture names, you can pass the `PLATFORM` option.

Finally, `vcpkg_msbuild_install()` defaults to building the `Rebuild` target.
If this is not correct for your build system, you should pass the `TARGET` option.

`vcpkg_msbuild_install()` defaults to parallel build;
if your project does not support that,
you should pass the `DISABLE_PARALLEL` option.

[`vcpkg_msbuild_clean`()]: vcpkg_msbuild_clean.md

## Source
[ports/vcpkg-msbuild/vcpkg\_msbuild\_install.cmake](https://github.com/Microsoft/vcpkg/blob/master/ports/vcpkg-msbuild/vcpkg_msbuild_install.cmake)

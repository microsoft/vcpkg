# The ANGLE vcpkg port

The ANGLE port's buildsystem is based off of [WebKit's approach](https://github.com/WebKit/WebKit/tree/main/Source/ThirdParty/ANGLE) to converting ANGLE's buildsystem to CMake.

Details:

- `cmake-buildsystem/CMakeLists.txt`
   - This is an augmented version of WebKit's [CMakeLists.txt](https://github.com/WebKit/WebKit/blob/main/Source/ThirdParty/ANGLE/CMakeLists.txt), with vcpkg edits and additions.
- `cmake-buildsystem/*.cmake`
   - These are configuration files based on [WebKit's approach](https://github.com/WebKit/WebKit/tree/main/Source/ThirdParty/ANGLE), with some minor vcpkg edits (and renaming `PlatformGTK` to `PlatformLinux`)
- `cmake-buildsystem/generated/*.cmake`
   - These are generated from the upstream ANGLE .gni files using WebKit's [gni-to-cmake.py](https://github.com/WebKit/WebKit/blob/main/Source/ThirdParty/ANGLE/gni-to-cmake.py) conversion script (see below)


## Updating the ANGLE vcpkg port

1. Select a new ANGLE version

Recommendation: Follow the recommendations in the libANGLE "[Choosing an ANGLE branch](https://github.com/google/angle/blob/master/doc/ChoosingANGLEBranch.md#matching-a-chromium-release-to-an-angle-branch)" guide, and find the branch that matches the current Chromium Stable.

2. [Find the branch](https://github.com/google/angle/branches) (usually `chromium/<version>`) and latest commit on that branch, and update the following variables in `portfile.cmake`:
   - `ANGLE_COMMIT`
   - `ANGLE_VERSION`
   - `ANGLE_SHA512`

3. Check the `DEPS` file at that ANGLE commit, for the commit used in `'third_party/zlib'`, and update `ANGLE_THIRDPARTY_ZLIB_COMMIT` in `portfile.cmake` if necessary.

4. Download the latest [gni-to-cmake.py](https://github.com/WebKit/WebKit/blob/main/Source/ThirdParty/ANGLE/gni-to-cmake.py) conversion script from WebKit.

5. Run `convert-angle-to-cmake.sh <path/to/checked/out/ANGLE/commit>`, which uses `gni-to-cmake.py` to produce the generated `*.cmake` files:
   - Compiler.cmake
   - GLESv2.cmake
   - D3D.cmake
   - GL.cmake
   - Metal.cmake

6. Attempt to build. You may have to tweak the `CMakeLists.txt`, `Platform*.cmake` files, etc. Check with the latest files in [WebKit's repo](https://github.com/WebKit/WebKit/tree/main/Source/ThirdParty/ANGLE) to see if any updates need to be ported to the vcpkg files.

7. Check headers against `opengl-registry` - make sure headers are similar.
> angle defines some additional entrypoints.
> opengl-registry should be latest before updating angle

8. Complete all the other normal steps in the [Maintainer Guide](/docs/maintainers/maintainer-guide.md)

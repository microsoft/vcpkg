# [UniConv] Add new port: uniconv

## Describe your pull request:
This PR adds a new port for [UniConv](https://github.com/hesphoros/UniConv), a C++ library for variable encoding conversion, to vcpkg.

- **Version:** 2.1.1
- **License:** MIT (note: some code is derived from GNU libiconv, which is LGPL; see LICENSE for details)
- **Homepage:** https://github.com/hesphoros/UniConv
- **Dependencies:** vcpkg-cmake-config
- **Features:** None (core only)

### Port highlights
- Cross-platform CMake build, generates config.h automatically.
- CMake config files are properly installed and fixed up for find_package(UniConv CONFIG REQUIRED).
- All vcpkg post-build policies and warnings are handled.
- LICENSE is installed to copyright.

### Testing
- Port tested locally on Linux with overlay-ports and vcpkg-cmake-config helper.
- find_package(UniConv) works as expected in downstream CMake projects.

### Checklist
- [x] LICENSE and metadata are correct
- [x] vcpkg_cmake_config_fixup used
- [x] No post-build warnings
- [x] Version matches release/tag
- [x] Local overlay-ports install passes

---

## How to use this port locally
```bash
./vcpkg install --overlay-ports=/path/to/UniConv/contrib/vcpkg/ports uniconv
```

---

## Notes for vcpkg maintainers
- Please verify license metadata and bundled LGPL code.
- If possible, prefer using a release tarball for the source URL in portfile.cmake.
- If you have any questions, please contact the UniConv maintainer.

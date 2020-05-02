## # vcpkg_test_cmake
##
## Tests a built package for CMake `find_package()` integration.
##
## ## Usage:
## ```cmake
## vcpkg_test_cmake(PACKAGE_NAME <name> [MODULE])
## ```
##
## ## Parameters:
##
## ### PACKAGE_NAME
## The expected name to find with `find_package()`.
##
## ### MODULE
## Indicates that the library expects to be found via built-in CMake targets.
##
function(vcpkg_test_cmake)
  # The following issues need to be addressed before re-enabling this function.
  #   1. Use the actual vcpkg toolchain file.
  #   2. Select a generator in the same method as vcpkg_configure_cmake() as though the PREFER_NINJA flag was always passed.
  #   3. Fully emulate the toolchain file for the just-built package (just adding it to CMAKE_PREFIX_PATH is not enough).
  return()
endfunction()

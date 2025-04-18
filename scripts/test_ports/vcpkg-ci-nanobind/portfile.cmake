set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# This test does not support cross-compilation due to nanobind's usage of the
# Python interpreter to figure out Python module suffix.
if(VCPKG_CROSSCOMPILING)
    message(WARNING "Skipping vcpkg-ci-nanobind because it is not expected to work when cross-compiling")
    return()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wjakob/nanobind_example
    REF 4b5c9bd484dec77e085a188dcefc536aed69aae9
    SHA512 ec7eeb25b5c5ee2e8bbcc48e78719dc6e5211cf54794dd3c370ad3e8d685fbc8b79435890da3b9481656169efaa87b77e3ea55ce864efd670dd9ea0600dee77d
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_build()

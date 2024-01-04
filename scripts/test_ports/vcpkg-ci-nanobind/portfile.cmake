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
    REF cc116d7c87d2e19c9c8146464c6ae7ed17620eec
    SHA512 cdb0eb09b1c03c0dea291daf876a85f9d5641f57747786cd2289d0aa4c8e3f34bd2809c351b3231fb80a358615086ee0e687ce23999a9ae012f75b000bdeef10
    HEAD_REF master
)

# This is needed to correctly build/link against a debug build of Python on
# Windows
string(APPEND VCPKG_CXX_FLAGS_DEBUG " -DPy_DEBUG")
string(APPEND VCPKG_C_FLAGS_DEBUG " -DPy_DEBUG")

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_build()

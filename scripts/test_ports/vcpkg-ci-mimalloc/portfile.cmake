set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF "v${VERSION}"
    SHA512 616351e549707318c1f8b164251141684a73d5bf8205b905736f48ab21fbb19bfaa4d52c4e63642fcb144345b6a5331944b6c8e0827925000553e46f2c2c31e9
    HEAD_REF master
    PATCHES
        build-type.diff
        vcpkg-tests.diff
)
# Ensure that the test uses the installed mimalloc only
file(REMOVE_RECURSE
    "${SOURCE_PATH}/bin"
    "${SOURCE_PATH}/include"
    "${SOURCE_PATH}/src"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/test"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CURRENT_PORT_DIR}/vcpkg-tests.cmake"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

set(ENV{MIMALLOC_VERBOSE} 1)
set(ENV{MIMALLOC_SHOW_ERRORS} 1)
set(ENV{MIMALLOC_DISABLE_REDIRECT} 1)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" OR NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(TOOL_NAMES pkgconfig-override-cxx AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

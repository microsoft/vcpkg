set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF "v${VERSION}"
    SHA512 55262050f63868e3029cd929a74d312dc0f34b606534b1d0b3735eecc8eed68aae97523a50228b4ac4044e1e03192f2909440e3a27607e2d364607ac0bda828f
    HEAD_REF master
    PATCHES
        build-type.diff
        vcpkg-tests.diff
trace.diff
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
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        "-DVCPKG_TESTS=${CURRENT_PORT_DIR}/vcpkg-tests.cmake"
)

set(ENV{MIMALLOC_VERBOSE} 1)
set(ENV{MIMALLOC_SHOW_ERRORS} 1)
set(ENV{MIMALLOC_DISABLE_REDIRECT} 1)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

vcpkg_copy_tools(TOOL_NAMES pkgconfig-override-cxx AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

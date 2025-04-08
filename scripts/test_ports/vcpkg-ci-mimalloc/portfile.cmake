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

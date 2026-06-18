set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/mimalloc
    REF "v${VERSION}"
    SHA512 a674dbe119e080630de0af12a972af9fb1ac3611413fd5a7eb14f61e47af620f6368a28e8849757136fcc1c3c4f8f776cfa0f351d3f0ef463eff98fdf8c4db52
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
        "-DFEATURES=${FEATURES}"
)

set(ENV{MIMALLOC_VERBOSE} 1)
set(ENV{MIMALLOC_SHOW_ERRORS} 1)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" OR NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_copy_tools(TOOL_NAMES pkgconfig-override-cxx AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

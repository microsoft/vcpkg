include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "This port currently only supports x64 architecture")
endif()

set(PATCHES forge_targets_fix.patch)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND PATCHES static_build.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arrayfire/forge
    REF 4de4239faa579e1d9bb7fb6bfe048a938ccce518
    SHA512 fd48375713c8c6646a8d4fa140e8a4b631e697c5f011656a0ca4c15c8288b47bfe1826c6cfa65c8f146a7b9dcd146058502a099e9477f92481cbc62556660ccd
    HEAD_REF master
    PATCHES ${PATCHES}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFG_BUILD_DOCS=OFF
        -DFG_BUILD_EXAMPLES=OFF
        -DFG_INSTALL_BIN_DIR=bin
        -DFG_WITH_FREEIMAGE=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(GLOB DLLS ${CURRENT_PACKAGES_DIR}/bin/* ${CURRENT_PACKAGES_DIR}/debug/bin/*)
list(FILTER DLLS EXCLUDE REGEX "forge\\.dll\$")
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/examples
    ${CURRENT_PACKAGES_DIR}/examples
    ${DLLS}
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/forge RENAME copyright)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lusipad/matiec-cmake
    REF v0.2.1
    SHA512 CB00B2F22E72E3B758D25B84C248228197868D50FA974AEE90FA16A784D5014F41F3EA71B049376F2A01DCAE0342D4A7F842E3F8C1D54E2A3840E213A0A9BD9C
    HEAD_REF master
)

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)

get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
vcpkg_add_to_path("${BISON_DIR}")
vcpkg_add_to_path("${FLEX_DIR}")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(MATIEC_BUILD_SHARED OFF)
    set(MATIEC_BUILD_STATIC ON)
else()
    set(MATIEC_BUILD_SHARED ON)
    set(MATIEC_BUILD_STATIC OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBISON_EXECUTABLE=${BISON}"
        "-DFLEX_EXECUTABLE=${FLEX}"
        "-DMATIEC_BUILD_TESTS=OFF"
        "-DMATIEC_BUILD_TOOLS=ON"
        "-DMATIEC_BUILD_SHARED=${MATIEC_BUILD_SHARED}"
        "-DMATIEC_BUILD_STATIC=${MATIEC_BUILD_STATIC}"
)

vcpkg_cmake_build()
vcpkg_cmake_install()

# Remove duplicate debug artifacts to satisfy vcpkg post-build checks.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_tools(
    TOOL_NAMES iec2c iec2iec
    AUTO_CLEAN
)

file(INSTALL "${SOURCE_PATH}/src/lib/"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/lib"
    FILES_MATCHING
    PATTERN "*.txt"
    PATTERN "*.h"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

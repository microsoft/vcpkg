vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO radarsat1/liblo
    REF "${VERSION}"
    SHA512 c9a1247213533f8d52a7ec71be884aa7595ace2575ed805dc35b2cc5fd93bed899d2a339291f142f440a6dea0747966cf847037b86b3981e44f6dd0c28dbba79
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cmake"
    OPTIONS
        -DTHREADING=ON
        -DWITH_STATIC=ON
        -DWITH_TESTS=OFF
)

vcpkg_cmake_install()

# Install needed files into package directory
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/liblo)
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(TOOL_NAMES oscsend oscdump oscsendfile AUTO_CLEAN)

# Remove unnecessary files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO radarsat1/liblo
    REF "${VERSION}"
    SHA512 3757675f908f6bb7be3414c2708c4958fd1dd92f55d22f394902b51a27230524ff9dd6500f85229a53d1383b71e3bc09c74c011c1b6b988ebd777283c58b7227
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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO radarsat1/liblo
    REF "${VERSION}"
    SHA512 ddcc41e8ea156ab9dfe8e8038542ac2a514bf65262fd00397590dd95f58551eb9aabbf5b85333edd3f4e5a261b55a96127a54d152dbb291a02de4b71fae255e3
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

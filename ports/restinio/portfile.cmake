vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/restinio
    REF a5b668560138da42158511880470b19988566568 # v.0.6.17
    SHA512 fc3cdab9c240ba30b5f4b800ec452442a38db93936d3f7557255e6e7e3176217413fa421afec8b155cfb498df5ca9fc48a74a8e9bf1903aa31c9824d26d9618c
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/vcpkg"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/restinio)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug")
# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
